defmodule StaekWeb.CustomComponents do
  use Phoenix.Component

  attr :groups, :any, required: true

  ## Flowbite List Group
  def user_groups(assigns) do
    ~H"""
    <div class="w-full text-sm font-medium text-gray-900 bg-white rounded-lg shadow-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white">
      <div class="flex flex-row w-full px-4 py-2 text-gray-600 font-bold bg-gray-200 border-b border-gray-200 first:rounded-t-lg last:rounded-b-lg dark:bg-gray-800 dark:border-gray-600">
        <div class="basis-2/3">Groups</div>
        <div class="basis-1/3">
          <a class="float-end hover:text-gray-400" href="/groups/new">&nbsp;+&nbsp;add</a>
        </div>
      </div>
      <a
        :for={group <- @groups}
        href={group.path}
        class="relative inline-flex items-center w-full px-4 py-2 last:rounded-b-lg cursor-pointer hover:bg-gray-100 focus:outline-none focus:ring-1 focus:ring-gray-400 dark:border-gray-600 dark:hover:bg-gray-600 dark:hover:text-white dark:focus:ring-gray-500 dark:focus:text-white"
      >
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
        <div class=""><%= group.name %></div>
      </a>
    </div>
    """
  end
end
