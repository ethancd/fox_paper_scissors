class PlayController < ApplicationController
  before_filter :ensure_slug, only: [:ai, :human]
  before_filter :find_game, only: [:move, :create, :offer_draw, :accept_draw]
  
  def ai
    @game = Game.find_or_create_by(slug: params[:slug])

    if @game.between_humans?
      return redirect_to action: "human", slug: params[:slug]
    end

    if @game.new?
      @game.build_vs_ai(@user.id, params[:depth])
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

    @game.incorporate_player(@user)

    render "index"
  end

  def move
    player = @game.players.find_by(user_id: @user.id)

    @move = @game.moves.new(player_id: player.id)
    @move.delta = @move.get_delta(params[:move][:piece], params[:move][:target])
    @move.save

    if @game.with_ai?
      FindMove.perform_later(@game)
    end

    render :json => { success: true } #@move.valid? }
  end

  def create
    render(status: 405) and return unless @game.complete?

    new_game = @game.build_next_game

    if new_game.is_ai_turn?
      FindMove.perform_later(new_game)
    end

    @game.broadcast_new_game(new_game.slug)
  end

  def offer_draw
    ActionCable.server.broadcast "game_#{params[:slug]}", {
      action: "draw_offered",
      offerer_name: @user.name,
      offerer_id: @user.id
    }

    if @game.with_ai?
      ai_respond_to_draw_offer
    end
  end

  def accept_draw
    broadcast_accept_draw
  end

  private
    def find_game
      @game = Game.find_by({slug: params[:slug] })
    end

    def ensure_slug
      unless Game.valid_slug?(params[:slug])
        redirect_to action: action_name, slug: Game.generate_slug
      end
    end

    def ai_respond_to_draw_offer
      ai = @game.ai_player
      reply = ai.reply_to_draw_offer(@game)

      ActionCable.server.broadcast "game_#{params[:slug]}", {
        action: "draw_considered",
        message: reply[:message]
      }

      if reply[:accept]
        broadcast_accept_draw
      end
    end

    def broadcast_accept_draw
      ActionCable.server.broadcast "game_#{params[:slug]}", {
        action: "draw_accepted"
      }
    end
end