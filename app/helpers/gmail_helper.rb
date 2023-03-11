
module GmailHelper
    def get_messages(token, query)
      uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/messages?q=#{query}");
      mail_ids = get_mail_infos(session[:access_token],uri)["messages"]
      mails = mail_ids.map do |mail_id|
        uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/messages/#{mail_id["id"]}")
        get_mail_infos(token,uri)["snippet"]
      end
      mails
    end
    def get_mail_infos(token,uri)
      request = Net::HTTP::Get.new(uri.request_uri)
    
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{token}"
      response = http.request(request)

      JSON.parse(response.body)
    end
end