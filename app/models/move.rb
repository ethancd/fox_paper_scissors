class Move < ApplicationRecord
  include GameGrammar

  belongs_to :game
  belongs_to :player

  after_create :update_board
  after_commit :broadcast_update

  def update_board
    board = self.game.board
    position = apply_delta_to_board_position(board.position, self.delta)
    self.game.board.position = position

    board.save
  end

  def broadcast_update
    self.game.broadcast_position_update(self.player.color)
  end
end
