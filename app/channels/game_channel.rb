# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_slug]}"

    @game = Game.find_by(slug: params[:game_slug])
    new_player = @game.players.find_by({user_id: user_id})
    pieces = @game.board.nil? ? [] : @game.board.pieces
    position = @game.board.nil? ? "" : @game.board.position

    ActionCable.server.broadcast "game_#{params[:game_slug]}", {
      action: "player_joined_game",
      pieces: pieces.to_json,
      position: position,
      player: new_player.to_json({user_id: user_id})
    }
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
