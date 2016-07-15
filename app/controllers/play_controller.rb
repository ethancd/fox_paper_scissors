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

    render "index"
  end

  def human
    @game = Game.find_or_create_by(slug: params[:slug])

    if @game.with_ai?
      return redirect_to action: "ai", slug: params[:slug]
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
      delta = opponent.move(@game.board.position, opponent.color)
      @move = @game.moves.create!({delta: delta, player_id: opponent.id })
    end

    render :json => { success: true } #@move.valid? }
  end

  private
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
      players = Game.build_players(user_id1, user_id2)
      @game.players.create(players)

      @game.create_board
      @game.create_chat
      @game.save

      @game
    end
end