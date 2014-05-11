require 'uri'
require 'net/http'
require 'timeout'
require 'json'

class BitcasaException < StandardError; end

# = This is Bitcasa Client library.
class BitcasaClient
  attr_accessor :id, :secret, :redirect_url, :access_token
  attr_accessor :proxy_host, :proxy_port, :proxy_user, :proxy_pwd
  attr_accessor :request_timeout

  BASE_URL = 'https://developer.api.bitcasa.com/v1'
  DEFAULT_REQUEST_TIMEOUT = 3

  # == initialize function
  # +id+: client_id for Bitcasa API
  # +secret: client secret for Bitcasa API
  def initialize(id, secret, redirect_url, access_token = nil)
    self.id = id
    self.secret = secret
    self.redirect_url = redirect_url
    self.access_token = access_token
    self.request_timeout = DEFAULT_REQUEST_TIMEOUT
  end

  # == set proxy information
  def proxy(proxy_host, proxy_port, proxy_user, proxy_pwd)
    self.proxy_host = proxy_host
    self.proxy_port = proxy_port
    self.proxy_user = proxy_user
    self.proxy_pwd = proxy_pwd
  end

  # == get oauth2 authorize URL
  # +state+: state value for Bitcasa API
  def authorize_url(state = nil)
    param = {
      client_id: id,
      response_type: :code,
      redirect: redirect_url
    }

    if state
      param.merge!(state: state)
    end

    bc_url('/oauth2/authorize', param)
  rescue => e
    raise BitcasaException, e.to_s, e.backtrace
  end

  # == get oauth token
  # +code+: auth code which is given from oauth2/authorize request
  def token(code)
    param = {
      secret: secret,
      grant_type: :authorization_code,
      code: code,
      redirect_uri: redirect_url
    }

    res = send_request('/oauth2/token', param)
  end

  private

  # == convert hash to URL query string
  # +h+: hash to convert query parameter
  # +return+: string converted from parameter hash
  def query(h)
    h.map { |k, v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" }.join('&')
  end

  # == get Bitcasa API URL
  # +return+: Bitcasa API URL based on path and param
  def bc_url(path, param)
    "#{BASE_URL}#{path}?#{query(param)}"
  end

  def send_request(path, param)
    client_class = nil
    if proxy_host && proxy_port
      client_class = Net::HTTP::Proxy(proxy_host, proxy_port,
                                      proxy_user, proxy_pwd)
    else
      client_class = Net::HTTP
    end

    res = nil
    uri = URI.parse(bc_url(path, param))
    http = client_class.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
    end
    Timeout.timeout(request_timeout) do
      http.start do |con|
        res = con.get("#{uri.path}?#{uri.query}")
      end
    end

    unless Net::HTTPOK === res
      fail BitcasaException, "invalide API status code: #{res.code}"
    end

    JSON.parse(res.body)
  rescue BitcasaException
    raise
  rescue Timeout::Error => e
    raise BitcasaException, 'API request timeout', e.backtrace
  rescue StandardError => e
    raise BitcasaException, e.to_s, e.backtrace
  end
end
