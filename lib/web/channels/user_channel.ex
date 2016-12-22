defmodule Brando.UserChannel do
  @moduledoc """
  Channel for user specific interaction.
  """
  @interval 1000

  use Phoenix.Channel

  intercept [
    "alert",
    "set_progress",
    "increase_progress"
  ]

  def join("user:lobby", _auth_msg, socket) do
    {:ok, %{user_id: socket.assigns.user_id}, socket}
  end

  def join("user:" <> user_id, _auth_msg, socket) do
    if socket.assigns.user_id == String.to_integer(user_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_out("alert", payload, socket) do
    push socket, "alert", payload
    {:noreply, socket}
  end

  def handle_out("set_progress", payload, socket) do
    push socket, "set_progress", payload
    {:noreply, socket}
  end

  def handle_out("increase_progress", payload, socket) do
    push socket, "increase_progress", payload
    {:noreply, socket}
  end

  def alert(user, message) do
    Brando.endpoint.broadcast!("user:" <> Integer.to_string(user.id), "alert", %{message: message})
  end

  def set_progress(user, value) do
    Brando.endpoint.broadcast!("user:" <> Integer.to_string(user.id), "set_progress", %{value: value})
  end

  def increase_progress(user, value) do
    Brando.endpoint.broadcast!("user:" <> Integer.to_string(user.id), "increase_progress", %{value: value})
  end
end