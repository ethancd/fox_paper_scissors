# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages"

    ActionCable.server.broadcast "messages", {action: "user_joined", msg: ""}
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
