GameButton = Struct.new(:action, :disabled) do 
  ButtonTexts = {
    "new-game" => "New Game!",
    "offer-draw" => "Offer Draw",
    "accept-draw" => "Accept Draw"
  }

  def text
    ButtonTexts[action]
  end
end
