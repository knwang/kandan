class UsersController < ApplicationController
  before_filter :set_as_current_user_if_me, :only => :show

  def index
    respond_to do |format|
      format.json { render :json => @users }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @user }
    end
  end

  private
  def set_as_current_user_if_me
    @user = current_user if params[:id] = 'me'
  end
end
