defmodule DigitsWeb.PageLive do
  @moduledoc """
  PageLIve LiveView
  """

  use DigitsWeb, :LiveView

  def mount(_params, _session, socket) do
    {:ok,
      assign(socket, %{prediction: nil})}
  end
end
