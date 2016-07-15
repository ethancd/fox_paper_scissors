class Move < ApplicationRecord
  include GameGrammar

  belongs_to :game
  belongs_to :player

  after_create :update_board

  def update_board
    board = self.game.board
    position = apply_delta_to_board_position(board.position, self.delta)
    self.game.board.position = position

    board.save
  end
end
