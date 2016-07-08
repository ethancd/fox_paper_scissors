require 'securerandom'

class PlayController < ApplicationController
  def ai
  end

  def human
    redirect_to action: "human", id: generate_id unless valid_id(params[:id])
  end

  private
    def valid_id(id)
      !!/^[0-9|a-f]{8}$/.match(id)
    end

    def generate_id
      SecureRandom.hex(4)
    end
end