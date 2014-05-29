require 'bitcasa_client'

class Bc::AuthController < ApplicationController
  def login
    reset_session
    redirect_to bitcasa_client.authorize_url
  end

  def return
    reset_session

    unless params[:code]
      logger.info 'no code'
      @error_msg = 'invalid request'
      return render template: 'bc/auth/return_error'
    end
    bc = bitcasa_client
    bc.token(params[:code])
    profile = bc.user_profile

    logger.debug(profile.inspect)

    @user = User.find_or_create_by(provider: Provider::BITCASA,
                                   uid: profile[:id])
    logger.debug(profile.inspect)
    @user.token = bc.access_token
    @user.name = profile[:display_name]
    @user.save!
    session[:user_id] = @user.id
    redirect_to folder_list_path
  rescue BCTimeoutException => e
    logger.error "error: #{e}"
    @error_msg = 'Bitcasa API request timeout'
    return render template: 'bc/auth/return_error'
  rescue => e
    logger.error "error: #{e}"
    @error_msg = 'unknown error'
    return render template: 'bc/auth/return_error'
  end

  private

  def bitcasa_client
    bc = BitcasaClient.new(ENV['BC_CLIENT_ID'], ENV['BC_CLIENT_SECRET'],
                           url_for(action: :return))
    bc.request_timeout = 10
    bc
  end
end
