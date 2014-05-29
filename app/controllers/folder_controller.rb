class FolderController < ApplicationController
  def list
    if session[:user_id]
      @user = User.find(session[:user_id])
    end
  end
end
