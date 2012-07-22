#!/usr/bin/env ruby

cwd = File.expand_path(File.dirname(__FILE__))

require "net/pop"
require File.join(cwd, "..", "lib", "issue")

server = ENV["ACETONE_POP_SERVER"]
port   = ENV["ACETONE_POP_PORT"] || 995

username = ENV["ACETONE_POP_USERNAME"]
password = ENV["ACETONE_POP_PASSWORD"]

newsletter_email = ENV["ACETONE_POP_NEWSLETTER_EMAIL"]

cacert = File.join(cwd, "..", "ssl", "cacert.pem")

Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_PEER, cacert)

Net::POP3.start(server, port, username, password) do |pop3|
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
      issue = Acetone::Issue.new
      issue.links = news.scan(/https?:\/\/[^\s<]*\w\/?/).uniq
      issue.save
    end
  end
end
