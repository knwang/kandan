class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    if authentication_token = params[:authentication_token]
      session[:authentication_token] = authentication_token
    end
    @user ||= User.where(authentication_token: session[:authentication_token]).first
  end
  helper_method :current_user
end
