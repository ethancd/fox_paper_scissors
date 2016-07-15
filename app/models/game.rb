class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  def self.build_players(user_id1, user_id2)
    players = [{user_id: user_id1}, {user_id: user_id2}];
    #players.shuffle!

    players[0][:first] = true
    players[1][:first] = false

    players
  end

  def broadcast_position_update
    #actually broadcast on channel "#{game_slug}"
    ActionCable.server.broadcast "messages", {action: "position_update", message: self.board.position }
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
