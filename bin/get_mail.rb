#!/usr/bin/env ruby

require "net/pop"

server = ENV["ACETONE_POP_SERVER"]
port   = ENV["ACETONE_POP_PORT"] || 995

username = ENV["ACETONE_POP_USERNAME"]
password = ENV["ACETONE_POP_PASSWORD"]

newsletter_email = ENV["ACETONE_POP_NEWSLETTER_EMAIL"]

cacert = File.join(File.expand_path("..", Dir.pwd), "ssl", "cacert.pem")

Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_PEER, cacert)

Net::POP3.start(server, port, username, password) do |pop3|
  unless pop3.mails.empty?
    pop3.each_mail do |mail|
      contents = mail.all
      if contents =~ /#{newsletter_email}/
        selection = false
        news      = ""
        contents.each_line do |line|
          case line
          when /News<br>/
            selection = true
          when /(Sponsors?|Events|Tools)<br>/
            break if selection
          end
          if selection
            news += line.chomp.chomp("=")
          end
        end
        urls = news.scan(/https?:\/\/[^\s<]*\w\/?/).uniq
        puts urls.inspect
      end
    end
  end
end
