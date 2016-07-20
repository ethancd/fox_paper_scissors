class Player < ApplicationRecord
  include AI
  belongs_to :game
  belongs_to :user

  validates_presence_of :user
  
  COMPUTER_PLAYER_USER_ID = "34e1d79e-22d8-4575-b617-e9cadca20e9e".freeze

  def get_noun(user_id)
    return "AI" if ai?

    self.user_id == user_id ? "You" : "Them"
  end

  def user_name
    if ai?
      self.user.name + "_" + AI::AI_SEARCH_DEPTH.to_s
    else
      self.user.name
    end
  end

  def ai?
    self.user_id == COMPUTER_PLAYER_USER_ID
  end

  def color
    self.first ? "red" : "blue"
  end
end
