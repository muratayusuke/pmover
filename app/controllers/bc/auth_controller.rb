require 'bitcasa_client'

class Bc::AuthController < ApplicationController
  def login
    unless session[:user]
      redirect_to bitcasa_client.authorize_url
    end
  end

  def return
    unless params[:code]
      # TODO: show error
    end
    res = bitcasa_client.token(params[:code])
    logger.debug(res['access_token'])
  end

  private

  def bitcasa_client
    BitcasaClient.new(ENV['BC_CLIENT_ID'], ENV['BC_CLIENT_SECRET'],
                      url_for(action: :return))
  end
end
