defmodule Staek.SyncService do
  use GenServer

  require Logger

  alias Phoenix.PubSub
  alias Staek.Repo

  @defaults %{
    sync_interval: :timer.seconds(3),
    db_version: 0
  }

  @topic __MODULE__ |> to_string()

  @doc false
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args |> Enum.into(@defaults), name: __MODULE__)
  end

  @impl true
  def init(state) do
    nodes = Application.fetch_env!(:staek, __MODULE__).nodes
    connect_nodes(nodes)
    PubSub.subscribe(state.pubsub, @topic)
    schedule_tick(state)

    state = %{state | db_version: Repo.get_crsql_db_version()}

    {:ok, state, {:continue, :sync_request}}
  end

  @impl true
  def handle_continue(:sync_request, state) do
    PubSub.broadcast(state.pubsub, @topic, sync_request(%{
      from_db_version: state.db_version
    }))

    {:noreply, state}
  end

  def handle_continue({:send_entries, from_db_version}, state) do
    entries = Repo.get_crsql_changes!(from_db_version)

    db_version =
      case entries do
        [] ->
          state.db_version

        [_ | _] ->
          entries |> List.last() |> Enum.into(%{}) |> Map.get("db_version")
      end

    Logger.debug(
      event: :send_entries,
      entries: length(entries),
      from_db_version: from_db_version,
      db_version: db_version
    )

    PubSub.broadcast(state.pubsub, @topic, entries(%{
      from_db_version: from_db_version,
      db_version: db_version,
      entries: entries
    }))

    state = %{state | db_version: db_version}

    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    db_version = Repo.get_crsql_db_version(state.db_version)

    Logger.debug(
      event: :tick,
      prev_db_version: state.db_version,
      db_version: db_version
    )

    schedule_tick(state)

    if state.db_version < db_version do
      {:noreply, state, {:continue, {:send_entries, state.db_version}}}
    else
      {:noreply, state}
    end
  end

  def handle_info(%{message: :sync_request, node: node} = message, state) when node != node() do
    Logger.debug(
      event: :sync_request,
      node: node,
      from_db_version: message.from_db_version
    )

    {:noreply, state, {:continue, {:send_entries, message.from_db_version}}}
  end

  def handle_info(%{message: :entries, node: node} = message, state) when node != node() do
    %{
      from_db_version: from_db_version,
      db_version: db_version,
      entries: entries
    } = message

    meta = %{
      entries: length(entries),
      node: node,
      from_db_version: from_db_version,
      db_version: db_version
    }

    Logger.debug(%{
      event: :received_entries,
    } |> Enum.into(meta))

    if state.db_version >= from_db_version && state.db_version <= db_version do
      {_, nil} = Repo.apply_crsql_changes(entries)

      Logger.debug(%{
        event: :applied_entries,
      } |> Enum.into(meta))

      state = %{state | db_version: db_version}

      {:noreply, state}
    else
      Logger.debug(%{
        event: :refused_entries,
        local_db_version: state.db_version
      } |> Enum.into(meta))

      {:noreply, state, {:continue, :sync_request}}
    end
  end

  def handle_info(message, state) do
    Logger.debug(
      event: :discarding_info,
      message: message
    )

    {:noreply, state}
  end

  defp connect_nodes(nodes) do
    Enum.each(nodes, &:net_adm.ping(&1))
  end

  defp schedule_tick(state) do
    Logger.debug(event: :schedule_tick)
    Process.send_after(self(), :tick, state.sync_interval)
  end

  defp entries(attrs) do
    %{
      from_db_version: _,
      db_version: _,
      entries: _
    } = attrs

    attrs |> Enum.into(%{
      message: :entries,
      node: node()
    })
  end

  defp sync_request(attrs) do
    %{
      from_db_version: _,
    } = attrs

    attrs |> Enum.into(%{
      message: :sync_request,
      node: node()
    })
  end
end
