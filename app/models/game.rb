class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  def shuffle_player_order
    self.players.shuffle
    self.players[0][:first] = true
    self.players[1][:first] = false

    self.save
  end

  def broadcast_position_update(color)
    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "position_update", 
      position: self.board.position,
      color: color
    }
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
