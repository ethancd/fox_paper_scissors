class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :moves, dependent: :destroy
  has_one :board, dependent: :destroy
  has_one :chat, dependent: :destroy

  delegate :position, to: :board, prefix: true, allow_nil: true

  COLORS = [:red, :blue]

  def build_vs_ai(user_id)
    human = Player.new({user_id: user_id})
    ai = AI.new({user_id: AI.id})

    build(*[human, ai].shuffle)
  end

  def build(player1, player2)
    player1.first = true
    player2.first = false

    players << player1
    players << player2
    player1.save
    player2.save

    create_chat
    create_board

    save
    self
  end

  def first_player
    players.find {|p| p.first }
  end

  def second_player
    players.find {|p| !p.first }
  end

  def build_next_game
    wipe_game_history
    swap_player_order

    save
    self
  end

  def wipe_game_history
    moves.delete_all
    board.reset_board
    players.each { |p| p.draws_considered = [] }
  end

  def incorporate_player(user)
    if players.length == 0 
      players.create({user_id: user.id, first: true})
      create_chat
    elsif players.length == 1 && players.first.user_id != user.id
      players.create({user_id: user.id, first: false})
      create_board
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
    players.each { |p| p.first = !p.first; p.save }

    save
  end

  def broadcast_position_update(last_moved_color)
    next_color = other_color(last_moved_color)

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
    first_player_won = (next_color == COLORS.last)
    winner = Player.find_by({game_id: self.id, first: first_player_won })

    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "checkmate", 
      winner: winner.user_name
    }
  end

  def broadcast_new_game
    broadcast_position_update(COLORS.last)

    ActionCable.server.broadcast "game_#{self.slug}", {
      action: "player_swap"
    }
  end

  def other_color(color)
    COLORS.find { |c| c != color }
  end

  def ai_player
      @ai_player ||= players.find { |player| player.ai? }
  end

  def current_player
    first = self.moves.length % 2 == 0

    self.players.find_by({first: first})
  end

  def which_color_turn?
    COLORS[self.moves.length % 2]
  end

  def is_ai_turn?
    with_ai? && current_player == self.players.to_a.find { |player| player.ai? }
  end

  def new?
    self.players.nil? || self.players.length == 0
  end

  def between_humans?
    !self.players.nil? && self.players.length == 2 && ai_player.nil?
  end

  def with_ai?
    ai_player.present?
  end

  def complete?
    !!result
  end
end
