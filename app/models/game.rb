class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  def shuffle_player_order
    players = self.players.shuffle
    players[0][:first] = true
    players[1][:first] = false

    self.players = players
    self.save
  end

  def swap_player_order
    self.players.each do |player|
      player.first = !player.first
      player.save
    end
  end

  def broadcast_position_update(last_moved_color)
    next_color = last_moved_color == "red" ? "blue" : "red"

    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "position_update", 
      position: self.board.position,
      color: next_color
    }

    if self.board.checkmate?(next_color)
      broadcast_checkmate(next_color)
    end
  end

  def broadcast_checkmate(next_color)
    first_player_won = (next_color == "blue")
    winner = Player.find_by({game_id: self.id, first: first_player_won })

    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "checkmate", 
      winner: winner.user_name
    }
  end

  def broadcast_new_game
    broadcast_position_update("blue")

    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "player_swap"
    }
  end

  def current_player
    first = self.moves.length % 2 == 0

    self.players.find_by({first: first})
  end

  def which_color_turn?
    self.moves.length % 2 == 0 ? "red" : "blue"
  end

  def is_ai_turn?
    with_ai? && current_player == self.players.to_a.find { |player| player.ai? }
  end

  def new?
    self.players.nil? || self.players.length == 0
  end

  def between_humans?
    !self.players.nil? && self.players.length == 2 && self.players.all? { |player| !player.ai? }
  end

  def with_ai?
    !self.players.nil? && self.players.any? { |player| player.ai? }
  end
end
