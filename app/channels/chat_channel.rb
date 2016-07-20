# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:chat_id]}"
    @user = User.find(user_id)

    ActionCable.server.broadcast "chat_#{params[:chat_id]}", {action: "user_joined", text: "#{@user.name}" }
  end
end
