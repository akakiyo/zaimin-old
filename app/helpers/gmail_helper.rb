require "base64"
module GmailHelper
    def get_messages(token, query)
      uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/messages?q=#{query}");
      mail_ids = get_mail_infos(session[:access_token],uri)["messages"]
      if mail_ids.any?
        mails = mail_ids.map do |mail_id|
          puts mail_id
          uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/messages/#{mail_id["id"]}")
          get_mail_infos(token,uri)
        end
        payments = mails.map do |mail|
          get_payments(mail)
        end
      else
        puts "該当のメールがないです"
      end
      payments
    end
    def get_payments(mail)
      decoded_data = Base64.urlsafe_decode64(mail["payload"]["parts"][0]["body"]["data"]).force_encoding('utf-8')
      flag = false
      splited_payments = []
      for line in decoded_data.split(/\R/) do
        if line.include?("ショッピングご利用分合計金額") then
          break
        end
        if flag then
          splited_payments.push(extract_payment_info(line.gsub(/>*/,"").split(/\s+/)))
        end
        if line.include?("予定月") then
           flag = true
        end
      end
      splited_payments
    end
    def extract_payment_info(line)
      common_length = 10
      diff_length = line.length - common_length
      date_of_use = line[0]
      product_name = line.slice(1,1+diff_length).join(" ")
      price = line[4+diff_length]
      due_date = line[6+diff_length]
      return {"date_of_use": date_of_use,"product_name": product_name,"price": price,"due_date": due_date}
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