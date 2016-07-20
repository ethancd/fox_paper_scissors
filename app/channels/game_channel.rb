# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    return unless valid_slug(params[:game_slug]) 

    stream_from "game_#{params[:game_slug]}"

    @game = Game.find_by(slug: params[:game_slug])
    new_player = @game.players.find_by({user_id: user_id})
    position = @game.board.nil? ? "" : @game.board.position

    ActionCable.server.broadcast "game_#{params[:game_slug]}", {
      action: "player_joined_game",
      position: position,
      player: new_player.to_json({methods: [:color, :user_name] })
    }
  end

  def valid_slug(slug)
    !!/^[0-9|a-f]{8}$/.match(slug)
  end
end
