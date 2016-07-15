class User < ApplicationRecord
  include NameGenerator

  has_many :players
  has_many :messages, foreign_key: 'author_id'
  has_many :games, through: :players

  after_initialize :ensure_name

  def ensure_name
    self.name ||= generate_name
  end
end
