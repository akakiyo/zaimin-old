require 'net/http'
require 'launchy'
require 'signet/oauth_2/client'
require 'json'

class GmailController < ApplicationController
    include GmailHelper
    def redirect
        puts "client id",ENV['CLIENT_ID']
        client = Signet::OAuth2::Client.new({
            client_id: ENV['CLIENT_ID'],
            authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
            scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
            redirect_uri: "http://localhost:3000/gmail/callback"
          })
        # 表示されるURLをブラウザで開く
        redirect_to client.authorization_uri.to_s, allow_other_host: true
    end
    
    def callback
        client = Signet::OAuth2::Client.new({
            client_id: ENV['CLIENT_ID'],
            client_secret: ENV['CLIENT_SECRET'],
        })
        client.token_credential_uri = "https://oauth2.googleapis.com/token"
        client.code = params[:code]
        client.redirect_uri = url_for(action: :callback)
        response = client.fetch_access_token!
        session[:access_token] = response['access_token']
        redirect_to "http://localhost:3000/gmail/getmail", allow_other_host: true
    end

    def getmail
        query = "from:akpr.2816@gmail.com"
        payments  = get_messages(session[:access_token],query)
        puts payments
    end
end