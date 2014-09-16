require 'dropbox_sdk'

module Dbx
  # Authentication controller for dropbox
  class AuthController < ApplicationController
    def login
      client = DropboxOAuth2Flow.new(app_key, app_secret,
                                     url_for(:action => 'finish'),
                                     {}, nil)
      redirect_to client.start
    end

    def finish
    end

    private

    def app_key
      ENV['DBX_APP_KEY']
    end

    def app_secret
      ENV['DBX_APP_SECRET']
    end
  end
end
