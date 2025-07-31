defmodule ThirteenWeb.PageLive do
  use ThirteenWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # Read the txt file content
    file_path = Path.join([:code.priv_dir(:thirteen), "static", "swiftElixirWebSockets.txt"])

    content = case File.read(file_path) do
      {:ok, data} ->
        Logger.info("File read successfully, length: #{String.length(data)}")
        data
      {:error, reason} ->
        Logger.error("Failed to read file: #{inspect(reason)}")
        "Error: File not found"
    end

    socket = assign(socket, :content, content)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-screen p-4">
      <h1 class="text-3xl font-bold mb-4 text-center">🚀 Swift ↔ Elixir Replicate Integration</h1>

      <!-- Full-width, vertically scrollable container -->
      <div class="w-full h-[calc(100vh-120px)] bg-gray-50 border border-gray-300 rounded-lg overflow-y-auto">
        <pre class="p-6 text-sm font-mono whitespace-pre leading-relaxed"><%= @content %></pre>
      </div>
    </div>
    """
  end
end
