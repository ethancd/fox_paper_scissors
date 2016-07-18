class PlayController < ApplicationController
  before_filter :ensure_slug, only: [:ai, :human]

  def ai
    @game = Game.find_or_create_by(slug: params[:slug])

    if @game.between_humans?
      return redirect_to action: "human", slug: params[:slug]
    end

    if @game.new?
      @game = build_game(@user.id, Player::COMPUTER_PLAYER_USER_ID)
    end

    if @game.is_ai_turn?
      FindMove.set(wait: 3.seconds).perform_later(@game)
    end

    render "index"
  end

  def human
    @game = Game.find_or_create_by(slug: params[:slug])

    if @game.with_ai?
      return redirect_to action: "ai", slug: params[:slug]
    end

    if @game.players.length == 0 
      @game.players.create({user_id: @user.id, first: true})
      @game.create_chat
      @game.save
    elsif @game.players.length == 1 && @game.players[0].user_id != @user.id
      @game.players.create({user_id: @user.id, first: false})
      @game.create_board
      @game.save
    end

    render "index"
  end

  def move
    @game = Game.find_by({slug: params[:slug] })
    player = @game.players.find_by(user_id: @user.id)

    @move = @game.moves.new(player_id: player.id)
    @move.delta = @move.get_delta(params[:move][:piece], params[:move][:target])
    @move.save

    opponent = @game.players.find { |player| player.user_id != @user.id }
    if opponent.ai?
      FindMove.perform_later(@game)
      #ai_move
    end

    render :json => { success: true } #@move.valid? }
  end

  def create
    @game = Game.find_by({slug: params[:slug] })
    @game.moves.delete_all
    @game.board.reset_board
    @game.swap_player_order

    @game.board.save
    @game.save

    @game.broadcast_new_game

    first_player = @game.players.find { |player| player.first }
    if first_player.ai?
      FindMove.perform_later(@game)
      #ai_move
    end
  end

  private
    def ai_move
      ai = @game.players.find { |player| player.ai? }
      delta = ai.move(@game.board.position, ai.color, {fuzzy: true})

      if !delta.nil?
        @game.moves.create!({delta: delta, player_id: ai.id })
      end
    end

    def ensure_slug
      unless valid_slug(params[:slug])
        redirect_to action: action_name, slug: generate_new_slug
      end
    end

    def valid_slug(slug)
      !!/^[0-9|a-f]{8}$/.match(slug)
    end

    def generate_new_slug
      loop do
        slug = SecureRandom.hex(4)
        return slug if Game.find_by(slug: slug) == nil
      end 
    end

    def build_game(user_id1, user_id2)
      @game.players.new([{user_id: user_id1, first: true}, {user_id: user_id2, first: false}])
      @game.shuffle_player_order

      @game.create_chat
      @game.create_board
      @game.save

      @game
    end
end