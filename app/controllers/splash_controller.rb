class SplashController < ApplicationController
  def index
    @board = Board.new
  end
end