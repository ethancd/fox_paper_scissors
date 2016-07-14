class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :get_user

  def get_user
    if cookies[:user_id]
      @user = User.find_or_create_by(id: cookies[:user_id])
    else
      @user = User.create
    end
  end
end


