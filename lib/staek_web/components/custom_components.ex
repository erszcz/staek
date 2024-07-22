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

  def user_groups(assigns) do
    ~H"""
    <.list_group title="Groups" items={@groups}>
      <:header_button>
        <a class="float-end hover:text-gray-400" href="/groups/new">&nbsp;+&nbsp;add</a>
      </:header_button>
      <:item_icon>
        <.group_item_icon />
      </:item_icon>
    </.list_group>
    """
  end

  def group_item_icon(assigns) do
    ~H"""
    <svg
      class="w-6 h-6 text-gray-800 dark:text-white mr-2"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      fill="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        fill-rule="evenodd"
        d="M12 6a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Zm-1.5 8a4 4 0 0 0-4 4 2 2 0 0 0 2 2h7a2 2 0 0 0 2-2 4 4 0 0 0-4-4h-3Zm6.82-3.096a5.51 5.51 0 0 0-2.797-6.293 3.5 3.5 0 1 1 2.796 6.292ZM19.5 18h.5a2 2 0 0 0 2-2 4 4 0 0 0-4-4h-1.1a5.503 5.503 0 0 1-.471.762A5.998 5.998 0 0 1 19.5 18ZM4 7.5a3.5 3.5 0 0 1 5.477-2.889 5.5 5.5 0 0 0-2.796 6.293A3.501 3.501 0 0 1 4 7.5ZM7.1 12H6a4 4 0 0 0-4 4 2 2 0 0 0 2 2h.5a5.998 5.998 0 0 1 3.071-5.238A5.505 5.505 0 0 1 7.1 12Z"
        clip-rule="evenodd"
      />
    </svg>
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
            <span class="text-sm">
              <%= case expense.creditors do
                [user] -> user
                _ -> "others"
              end %> paid
            </span>
            <br /><%= expense.total_credit %>
          </div>
          <div class="basis-1/5 text-right pr-4">
            <span class="text-sm">you owe</span> <br /><%= expense.user_debit %>
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
