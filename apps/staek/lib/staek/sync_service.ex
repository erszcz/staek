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
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Logger.debug(__MODULE__: :tick)

    ## TODO: db_version should be stored persistently across app restarts to avoid
    ##       resending db history since its creation
    entries = Repo.get_crsql_changes!(state.db_version)

    db_version = case entries do
      [] ->
        state.db_version
      [_|_] ->
        entries |> List.last() |> Enum.into(%{}) |> Map.get("db_version")
    end

    Logger.debug([
      event: :tick,
      entries: length(entries),
      prev_db_version: state.db_version,
      db_version: db_version
    ])

    ## TODO: watch out for out of order messages and missing updates!
    PubSub.broadcast(state.pubsub, @topic, %{
      message: :entries,
      from_db_version: state.db_version,
      to_db_version: db_version,
      entries: entries
    })

    schedule_tick(state)

    state =
      state
      |> Map.put(:db_version, db_version)

    {:noreply, state}
  end

  def handle_info(%{message: :entries} = message, state) do
    ## TODO: verify if it's safe to apply the changes,
    ##       i.e. there's no gap between our db_version and from_db_version
    %{
      from_db_version: _from_db_version,
      to_db_version: to_db_version,
      entries: entries
    } = message

    Logger.debug([
      event: :entries,
      entries: length(entries)
    ])

    {_, nil} = Repo.apply_crsql_changes(entries)

    state =
      state
      |> Map.put(:db_version, to_db_version)

    {:noreply, state}
  end

  defp connect_nodes(nodes) do
    Enum.each(nodes, &:net_adm.ping(&1))
  end

  defp schedule_tick(state) do
    Logger.debug(event: :schedule_tick)
    Process.send_after(self(), :tick, state.sync_interval)
  end
end
