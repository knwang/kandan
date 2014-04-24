class ApisController < ApplicationController
  
  def active_users
    respond_to do |format|
      format.json { render :json => ActiveUsers.all }
    end
  end

  def me
    respond_to do |format|
      format.json { render :json => current_user }
    end
  end

  def add_user
    User.create!(email: params[:email], full_name: params[:full_name], authentication_token: params[:authentication_token], admin: false)
    head(200)
  end
end
