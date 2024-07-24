defmodule StaekWeb.GroupHTML do
  use StaekWeb, :html

  embed_templates "group_html/*"

  @doc """
  Renders a group form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def group_form(assigns)

  def group_balances(assigns)

  attr :items, :any, required: true

  def group_expenses(assigns)

  def user_groups(assigns)

  def render_who_paid(who_paid, assigns) do
    case who_paid do
      {:current_user_paid, amount} ->
        assigns = assign(assigns, :amount, amount)

        ~H"""
        <span class="text-sm">you paid</span> <br /><%= @currency %> <%= @amount %>
        """

      {:another_user_paid, user, amount} ->
        assigns =
          assigns
          |> assign(:user, user)
          |> assign(:amount, amount)

        ~H"""
        <span class="text-sm"><%= @user %> paid</span> <br /><%= @currency %> <%= @amount %>
        """

      {:n_users_paid, n, amount} ->
        assigns =
          assigns
          |> assign(:n, n)
          |> assign(:amount, amount)

        ~H"""
        <span class="text-sm"><%= @n %> people paid</span> <br /><%= @currency %> <%= @amount %>
        """
    end
  end

  def render_user_debt(user_debt, assigns) do
    case user_debt do
      {:current_user_lent, amount} ->
        assigns = assign(assigns, :amount, amount)

        ~H"""
        <span class="text-sm">you lent</span> <br /><%= @currency %> <%= @amount %>
        """

      {:current_user_borrowed, amount} ->
        assigns = assign(assigns, :amount, amount)

        ~H"""
        <span class="text-sm">you borrowed</span> <br /><%= @currency %> <%= @amount %>
        """

      {:another_user_lent, user, amount} ->
        assigns =
          assigns
          |> assign(:user, user)
          |> assign(:amount, amount)

        ~H"""
        <span class="text-sm"><%= @user %> lent you</span> <br /><%= @currency %> <%= @amount %>
        """

      :not_involved ->
        ~H"""
        <span class="text-sm">not involved</span>
        """
    end
  end

  def render_balance(balance, assigns) do
    assigns =
      assigns
      |> assign(:user, balance.user)
      |> assign(:amount, balance.amount)

    case balance.status do
      :owes ->
        ~H"""
        <%= @user %> <br /> owes <%= @currency %> <%= @amount %>
        """

      :gets_back ->
        ~H"""
        <%= @user %> <br />gets back <%= @currency %> <%= @amount %>
        """
    end
  end
end
