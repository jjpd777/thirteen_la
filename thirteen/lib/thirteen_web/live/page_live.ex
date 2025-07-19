defmodule ThirteenWeb.PageLive do
  use ThirteenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-2xl font-bold">Welcome to Thirteen!</h1>
    """
  end
end
