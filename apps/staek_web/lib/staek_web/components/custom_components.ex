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

  attr :text, :any, required: true
  attr :items, :any, required: true

  def dropdown(assigns) do
    ~H"""
    <button
      id="dropdownHoverButton"
      data-dropdown-toggle="dropdownHover"
      data-dropdown-trigger="click"
      class="w-44 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-white font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-white"
      type="button"
    >
      <%= @text %>
      <svg
        class="ms-auto w-2.5 h-2.5"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 10 6"
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="m1 1 4 4 4-4"
        />
      </svg>
    </button>
    <!-- Dropdown menu -->
    <div
      id="dropdownHover"
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
    >
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdownHoverButton">
        <li :for={item <- @items}>
          <.link
            href={item.href}
            method={item[:method] || "get"}
            class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
          >
            <%= item.text %>
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end
