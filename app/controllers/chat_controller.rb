class ChatController < ApplicationController

  def respond
    ## 

    ActionCable.server.broadcast('messages', {
      action: "new_message",
      message: params[:text]
    })


    # response = build_response(params[:text])

    # render :json => response
  end

  private
    # def build_response(text)
    #   return { 
    #     text: text.upcase,
    #     color: dark_colors.sample
    #   }
    # end

    # def dark_colors
    #   return [
    #     "#85200c",
    #     "#990000",
    #     "#b4f506",
    #     "#bf9000",
    #     "#38761d",
    #     "#134f5c",
    #     "#1155cc",
    #     "#0b5394",
    #     "#351c75",
    #     "#741b47"
    #   ]
    # end
end