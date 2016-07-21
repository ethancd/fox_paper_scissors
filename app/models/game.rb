class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  delegate :position, to: :board, prefix: true, allow_nil: true

  def build_ai(user_id)
    build(*[user_id, AI.id].shuffle)
  end

  def build(user_id1, user_id2)
    players.new([{user_id: user_id1, first: true}, {user_id: user_id2, first: false}])
    
    create_chat
    create_board

    if ai_player.try(:first)
      FindMove.perform_later(self)
    end

    save

    self
  end

def first_player
  self.players.find {|p| p.first }
end

def second_player
  self.players.find {|p| !p.first }
end

def next
  build(second_player.user_id, first_player.user_id)  
end

def incorporate_player(user)
  if players.length == 0 
    players.create({user_id: user.id, first: true})
    create_chat
  elsif players.length == 1 && players.first.user_id != user.id
    players.create({user_id: user.id, first: false})
    create_board
  #elsif players.length >= 2
    #track spectators
  end

  save
end

def self.valid_slug?(slug)
  !!/^[0-9|a-f]{8}$/.match(slug)
end

def self.generate_slug
  loop do
    slug = SecureRandom.hex(4)
    return slug if find_by(slug: slug) == nil
  end 
end

  def shuffle_player_order
    players.first.first = [true, false].sample
    players.second.first = !players.first.first
    save
  end

  def swap_player_order
    players.each { |p| p.first = !p.first }

    save
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

  def result
    @result ||= board.checkmate?
  end

  def result=(value)
    @result = value
  end

  def draw!
    result = :draw
  end

  def ai_player
      @ai_player ||= players.find { |player| player.ai? }
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
    ai_player.present?
  end

  def complete?
    !!result
  end
end
