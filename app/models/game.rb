class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  # def shuffle_player_order
  #   players = self.players.shuffle
  #   players[0][:first] = true
  #   players[1][:first] = false

  #   self.players = players
  #   self.save
  # end

  def broadcast_position_update(color)
    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "position_update", 
      position: self.board.position,
      color: color
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
