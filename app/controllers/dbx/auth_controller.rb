require 'dropbox_sdk'

module Dbx
  # Authentication controller for dropbox
  class AuthController < ApplicationController
    def login
      reset_session
      redirect_to oauth2flow.start
    end

    def finish
      access_token, user_id, _url_state = oauth2flow.finish(params)
      user = User.find_or_create_by(provider: Provider::DROPBOX,
                                    uid: user_id)
      user.token = access_token
      user.save!

      reset_session
      session[:access_token] = access_token
      session[:user_id] = user.id
      # redirect_to folder_list_path
      redirect_to folder_list_path
    rescue DropboxOAuth2Flow::BadRequestError => e
      render text: "Error in OAuth 2 flow: Bad request: #{e}"
    rescue DropboxOAuth2Flow::BadStateError => e
      logger.info("Error in OAuth 2 flow: No CSRF token in session: #{e}")
      redirect_to(action: 'login')
    rescue DropboxOAuth2Flow::CsrfError => e
      logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
      render text: 'CSRF error'
    rescue DropboxOAuth2Flow::NotApprovedError => _e
      render text: 'Not approved?  Why not, bro?'
    rescue DropboxOAuth2Flow::ProviderError => e
      logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
      render text: 'Strange error.'
    rescue DropboxError => e
      logger.info "Error getting OAuth 2 access token: #{e}"
      render text: 'Error communicating with Dropbox servers.'
    end

    private

    def oauth2flow
      DropboxOAuth2Flow.new(app_key, app_secret,
                            url_for(action: 'finish'),
                            session, :_csrf_token)
    end

    def app_key
      ENV['DBX_APP_KEY']
    end

    def app_secret
      ENV['DBX_APP_SECRET']
    end
  end
end
