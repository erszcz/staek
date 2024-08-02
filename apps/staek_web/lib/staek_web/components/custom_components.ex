defmodule StaekWeb.CustomComponents do
  use Phoenix.Component

  attr :title, :any, required: true
  attr :items, :any, required: true
  slot :header_button
  slot :list_item

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
        class="relative inline-flex items-center w-full last:rounded-b-lg cursor-pointer hover:bg-gray-100 focus:outline-none focus:ring-1 focus:ring-gray-400 dark:border-gray-600 dark:hover:bg-gray-600 dark:hover:text-white dark:focus:ring-gray-500 dark:focus:text-white"
      >
        <%= render_slot(@list_item, item) %>
      </a>
    </div>
    """
  end
end
