# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_slug]}"

    ActionCable.server.broadcast "game_#{params[:game_slug]}", {action: "player_joined_game", message: "" }
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
