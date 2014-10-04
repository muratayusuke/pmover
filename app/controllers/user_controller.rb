class UserController < ApplicationController
  def view
    if session[:user_id]
      @user = User.find(session[:user_id])
    end
  end

  def update
    if session[:user_id]
      @user = User.find(session[:user_id])
      @user.email = params[:user][:email]
      @user.save!
    end

    redirect_to user_view_path
  end
end
