require 'net/http'
require 'launchy'
require 'signet/oauth_2/client'
require 'json'

class TransactionsController < ApplicationController
  include GmailHelper
  include ActionController::Cookies
  def redirect
    client = Signet::OAuth2::Client.new({
        client_id: ENV['CLIENT_ID'],
        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
        scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
        redirect_uri: "http://localhost:3000/transactions/callback"
        })

    render json: { redirect_url: client.authorization_uri.to_s}
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
    cookies[:access_token] = response['access_token']
    redirect_to 'http://localhost:3001/', allow_other_host: true
  end
  def create
    query = "from:akpr.2816@gmail.com"
  #   query = "from:kiyoto.a328@icloud.com"
    token = params[:gmail_access_token]
    payments  = get_messages(token,query)
    payments.each do |payment|
      payment.each do |transaction|
        Transaction.create(user_id: 1,name: transaction[:product_name],price: transaction[:price].delete(',').to_i,date_of_use: transaction[:date_of_use],due_date: transaction[:due_date]);
      end
    end
    render json: "ok"
  end
end
