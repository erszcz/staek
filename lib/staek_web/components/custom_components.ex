defmodule StaekWeb.CustomComponents do
  use Phoenix.Component

  attr :title, :any, required: true
  attr :items, :any, required: true
  slot :header_button
  slot :item_icon

  ## Flowbite List Group
  def list_group(assigns) do
    ~H"""
    <div class="w-full text-sm font-medium text-gray-900 bg-white rounded-lg shadow-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white">
      <div class="flex flex-row w-full px-4 py-2 text-gray-600 font-bold bg-gray-300 border-b border-gray-300 first:rounded-t-lg last:rounded-b-lg dark:bg-gray-800 dark:border-gray-600">
        <div class="basis-2/3"><%= @title %></div>
        <div class="basis-1/3">
          <div :if={@header_button != []}>
            <%= render_slot(@header_button) %>
          </div>
        </div>
      </div>
      <a
        :for={item <- @items}
        href={item.href}
        class="relative inline-flex items-center w-full px-4 py-2 last:rounded-b-lg cursor-pointer hover:bg-gray-100 focus:outline-none focus:ring-1 focus:ring-gray-400 dark:border-gray-600 dark:hover:bg-gray-600 dark:hover:text-white dark:focus:ring-gray-500 dark:focus:text-white"
      >
        <div :if={@item_icon != []}><%= render_slot(@item_icon) %></div>
        <div class=""><%= item.name %></div>
      </a>
    </div>
    """
  end

  attr :items, :any, required: true

  def expenses(assigns) do
    ~H"""
    <div :if={@items != []} class="flex flex-col">
      <div :for={expense <- @items} class="odd:bg-gray-100 last:rounded-b-lg">
        <a href="" class="block w-full flex flex-row">
          <div class="basis-2/5 text-xl m-auto px-4 py-3"><%= expense.name %></div>
          <div class="basis-2/5 text-right">
            <%= StaekWeb.GroupHTML.render_who_paid(expense.who_paid, assigns) %>
          </div>
          <div class="basis-1/5 text-right pr-4">
            <%= StaekWeb.GroupHTML.render_user_debt(expense.user_debt, assigns) %>
          </div>
        </a>
      </div>
    </div>
    <div :if={@items == []} class="p-4">
      No expenses recorded in this group
    </div>
    """
  end
end
