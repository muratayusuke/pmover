require 'bitcasa_client'

class Bc::AuthController < ApplicationController
  def login
    unless session[:user]
      bc = BitcasaClient.new(ENV['BC_CLIENT_ID'], ENV['BC_CLIENT_SECRET'],
                             url_for(action: :return))
      redirect_to bc.authorize_url
    end
  end

  def return
  end
end
