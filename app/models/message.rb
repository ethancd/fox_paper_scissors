class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :author, class_name: 'User'

  def get_formatted_text
    "#{self.author.name}: #{self.text}"
  end

  def get_color
    player = Player.find_by(game_id: chat.game_id, user_id: self.author_id)
    if !player.nil? 
      player.color == "red" ? colors[:red] : colors[:blue]
    else
      return colors[:default]
    end
  end

    private
      def colors
        {
          red: "#85200c",
          blue: "#1c4586",
          default: "#38761d",
        }
      end
end
