class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates_presence_of :user
  
  FIRST_PLAYER_COLOR = :red
  SECOND_PLAYER_COLOR = :blue

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

  def user_id
    user.id
  end

  def ai?
    false
  end

  def color
    self.first ? FIRST_PLAYER_COLOR : SECOND_PLAYER_COLOR
  end

  def as_json(options = {})
    result = super(options)
    result[:color] = color
    result[:user_name] = user_name
    result
  end
end
