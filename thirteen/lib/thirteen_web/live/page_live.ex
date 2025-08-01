defmodule ThirteenWeb.PageLive do
  use ThirteenWeb, :live_view
  require Logger

  # Define the available files
  @available_files [
    "swiftElixirWebSockets.txt",
    "websocketsElixirFirst.txt",
    "hotelAnalogy.txt"
  ]

  @impl true
  def mount(_params, _session, socket) do
    # Initialize with the first file
    socket =
      socket
      |> assign(:current_file, "swiftElixirWebSockets.txt")
      |> assign(:available_files, @available_files)
      |> load_file_content("swiftElixirWebSockets.txt")

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_file", _params, socket) do
    # Cycle through all available files
    current_index = Enum.find_index(@available_files, &(&1 == socket.assigns.current_file))
    next_index = rem(current_index + 1, length(@available_files))
    new_file = Enum.at(@available_files, next_index)

    socket =
      socket
      |> assign(:current_file, new_file)
      |> load_file_content(new_file)

    {:noreply, socket}
  end

  defp load_file_content(socket, filename) do
    file_path = Path.join([:code.priv_dir(:thirteen), "static", filename])

    content = case File.read(file_path) do
      {:ok, data} ->
        Logger.info("File read successfully: #{filename}, length: #{String.length(data)}")
        data
      {:error, reason} ->
        Logger.error("Failed to read file #{filename}: #{inspect(reason)}")
        "Error: File not found"
    end

    assign(socket, :content, content)
  end

  defp get_next_file_name(current_file) do
    case current_file do
      "swiftElixirWebSockets.txt" -> "WebSockets First"
      "websocketsElixirFirst.txt" -> "Hotel Analogy"
      "hotelAnalogy.txt" -> "Swift WebSockets"
      _ -> "Next File"
    end
  end

  defp get_display_name(filename) do
    case filename do
      "swiftElixirWebSockets.txt" -> "Swift WebSockets Architecture"
      "websocketsElixirFirst.txt" -> "WebSockets First Implementation"
      "hotelAnalogy.txt" -> "Hotel Analogy Explanation"
      _ -> filename
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-screen p-4">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-3xl font-bold text-center flex-1">🚀 Elwift Architecture</h1>
        <button
          phx-click="toggle_file"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
        >
          Switch to <%= get_next_file_name(@current_file) %>
        </button>
      </div>

      <!-- File indicator with progress -->
      <div class="mb-2 text-center">
        <span class="inline-block px-3 py-1 bg-gray-200 text-gray-700 rounded-full text-sm font-medium">
          <%= get_display_name(@current_file) %>
          (<%= Enum.find_index(@available_files, &(&1 == @current_file)) + 1 %>/<%= length(@available_files) %>)
        </span>
      </div>

      <!-- Full-width, vertically scrollable container -->
      <div class="w-full h-[calc(100vh-180px)] bg-gray-50 border border-gray-300 rounded-lg overflow-y-auto">
        <pre class="p-6 text-sm font-mono whitespace-pre leading-relaxed"><%= @content %></pre>
      </div>
    </div>
    """
  end
end
