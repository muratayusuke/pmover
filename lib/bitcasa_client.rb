require 'uri'

# This is Bitcasa Client library.
class BitcasaClient
  attr_accessor :id, :secret, :redirect_url, :access_token

  BASE_URL = 'https://developer.api.bitcasa.com/v1/'

  def initialize(id, secret, redirect_url, access_token = nil)
    self.id = id
    self.secret = secret
    self.redirect_url = redirect_url
    self.access_token = access_token
  end

  def authorize_url(state = nil)
    param = {
      client_id: id,
      response_type: :code,
      redirect: redirect_url
    }

    if state
      param.merge!(state: state)
    end

    "#{BASE_URL}oauth2/authorize?#{query(param)}"
  end

  private

  # convert hash to query string
  def query(h)
    h.map { |k, v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" }.join('&')
  end
end
