require 'bitcasa_client'

class Bc::AuthController < ApplicationController
  def login
    unless session[:user]
      redirect_to bitcasa_client.authorize_url
    end
  end

  def return
    unless params[:code]
      logger.info 'no code'
      @error_msg = 'invalid request'
      return render template: 'bc/auth/return_error'
    end
    access_token = bitcasa_client.token(params[:code])
    # @user = User.create(Provider.BITCASA.to_s, )
    logger.debug("token:#{access_token}")
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
