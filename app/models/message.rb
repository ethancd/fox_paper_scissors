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
      return colors.values[2..-1].sample
    end
  end

  private
    def colors
      {
        red: "#85200c",
        blue: "#1c4586",
        orange: "#b4f506",
        yellow: "#bf9000",
        green: "#38761d",
        violet: "#351c75",
        rose: "#741b47",
        black: "#000000",
        gray: "#666666"
      }
    end
end
