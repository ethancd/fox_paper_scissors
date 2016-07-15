class MessageController < ApplicationController

  def create
    params.inspect
    @message = Message.create(message_params)

    ActionCable.server.broadcast('messages', {
      action: "new_message",
      message: @message.get_formatted_text,
      color: @message.get_color
    })
  end

  private
    def message_params
      params.permit(:author_id, :chat_id, :text)
    end
end