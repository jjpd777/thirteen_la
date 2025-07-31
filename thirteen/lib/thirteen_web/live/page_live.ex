defmodule ThirteenWeb.PageLive do
  use ThirteenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Read the txt file content
    file_path = Path.join([:code.priv_dir(:thirteen), "static", "swiftElixirWebSockets.txt"])
    content = case File.read(file_path) do
      {:ok, data} -> data
      {:error, _} -> "File not found"
    end

    socket = assign(socket, :file_content, content)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4 pt-24">
      <h1 class="text-2xl font-bold mb-4">Swift Elixir WebSockets Diagram</h1>
      <pre class="bg-gray-100 p-4 rounded overflow-x-auto text-sm font-mono whitespace-pre"><%= @file_content %></pre>
    </div>
    """
  end
end
