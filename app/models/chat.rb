class Chat < ApplicationRecord
  belongs_to :game
  has_many :messages, dependent: :destroy
end
