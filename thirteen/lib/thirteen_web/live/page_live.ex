defmodule ThirteenWeb.PageLive do
  use ThirteenWeb, :live_view
  require Logger

  # Define the available files organized by category
  @available_files %{
    "elixir" => %{
      file: "elixir_architecture.txt",
      title: "Elixir Backend Deep Dive",
      description: "Detailed Phoenix & OTP implementation"
    },
    "swift" => %{
      file: "swift_architecture.txt",
      title: "Swift Client Architecture",
      description: "SwiftUI, MVVM & WebSocket client"
    },
    "unified" => %{
      file: "unified_architecture.txt",
      title: "Elwift Unified Vision",
      description: "Conceptual overview of the complete system"
    }
  }

  @impl true
  def mount(_params, _session, socket) do
    # Initialize with the unified view
    socket =
      socket
      |> assign(:current_tab, "unified")
      |> assign(:available_files, @available_files)
      |> load_file_content("unified")

    {:ok, socket}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    socket =
      socket
      |> assign(:current_tab, tab)
      |> load_file_content(tab)

    {:noreply, socket}
  end

  defp load_file_content(socket, tab_key) do
    file_info = @available_files[tab_key]
    filename = file_info.file
    file_path = Path.join([:code.priv_dir(:thirteen), "static", filename])

    content = case File.read(file_path) do
      {:ok, data} ->
        Logger.info("File read successfully: #{filename}, length: #{String.length(data)}")
        data
      {:error, reason} ->
        Logger.error("Failed to read file #{filename}: #{inspect(reason)}")
        "Error: File not found - #{filename}"
    end

    assign(socket, :content, content)
  end

  defp get_tab_info(tab_key) do
    @available_files[tab_key] || %{title: "Unknown", description: ""}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-screen p-4">
      <!-- Header -->
      <div class="text-center mb-6">
        <h1 class="text-4xl font-bold text-gray-800 mb-2">🚀 Elwift Architecture</h1>
        <p class="text-gray-600">Swift ❤️ Phoenix: Real-time AI Generation</p>
      </div>

      <!-- Tab Navigation -->
      <div class="flex justify-center mb-6">
        <div class="flex bg-gray-100 rounded-lg p-1">
          <%= for {tab_key, tab_info} <- @available_files do %>
            <button
              phx-click="switch_tab"
              phx-value-tab={tab_key}
              class={[
                "px-6 py-3 rounded-md font-medium transition-all duration-200",
                if(@current_tab == tab_key,
                  do: "bg-white text-blue-600 shadow-sm",
                  else: "text-gray-600 hover:text-gray-800"
                )
              ]}
            >
              <div class="text-sm font-semibold"><%= tab_info.title %></div>
              <div class="text-xs text-gray-500"><%= tab_info.description %></div>
            </button>
          <% end %>
        </div>
      </div>

      <!-- Content Display -->
      <div class="bg-white rounded-lg shadow-lg border">
        <!-- Content Header -->
        <div class="px-6 py-4 border-b bg-gray-50 rounded-t-lg">
          <h2 class="text-xl font-semibold text-gray-800">
            <%= get_tab_info(@current_tab).title %>
          </h2>
          <p class="text-sm text-gray-600 mt-1">
            <%= get_tab_info(@current_tab).description %>
          </p>
        </div>

        <!-- Content Area -->
        <div class="h-[calc(100vh-280px)] overflow-y-auto">
          <pre class="p-6 text-sm font-mono whitespace-pre leading-relaxed text-gray-800"><%= @content %></pre>
        </div>
      </div>
    </div>
    """
  end
end
