require "sinatra"
require "haml"
require "json"
require "uri"

require File.join(File.dirname(__FILE__), "lib", "issue")
require File.join(File.dirname(__FILE__), "lib", "user")
require File.join(File.dirname(__FILE__), "lib", "instapaper")

enable :sessions

get "/" do
  haml :index, :locals => {
    :success => session.delete(:success),
    :error   => session.delete(:error)
  }
end

get "/latest" do
  content_type "application/json"
  issue = Acetone::Issue.new
  issue.latest
  JSON.generate(issue.to_hash)
end

post "/user" do
  valid   = true
  success = false
  error   = false
  unless params.has_key?("action") && ["subscribe", "unsubscribe"].include?(params[:action])
    valid = false
  end
  unless params.has_key?("username") && !params[:username].empty?
    valid = false
  end
  if valid
    instapaper = Acetone::Instapaper.new
    if instapaper.get_access_token(params[:username], params[:password])
      if credentials = instapaper.current_credentials
        case params[:action]
        when "subscribe"
          user = Acetone::User.new
          user.user_id            = credentials[:user_id]
          user.oauth_token        = credentials[:oauth_token]
          user.oauth_token_secret = credentials[:oauth_token_secret]
          unless params[:latest_issue]
            issue = Acetone::Issue.new
            issue.latest
            user.last_issue = issue.created
          end
          if user.save!
            success = "Success! You are now subscribed!"
          else
            error = "Error! Please try again later."
          end
        when "unsubscribe"
          user = Acetone::User.new
          if user.load(credentials[:user_id])
            if user.delete!
              success = "Success! You unsubscribed, sorry to see you go."
            else
              error = "Error! Please try again later."
            end
          else
            error = "Error! Are you sure you have subscribed?"
          end
        end
      else
        error = "Error! Invalid Instapaper credentials."
      end
    else
      error = "Error! Invalid Instapaper credentials."
    end
  else
    error = "Error! You must provide a valid Instapaper Username."
  end
  session[:success] = success
  session[:error]   = error
  redirect back
end

post "/receiver" do
  if params[:from] == ENV["ACETONE_NEWSLETTER_EMAIL"]
    selection = false
    news      = ""
    params[:plain].each_line do |line|
      case line
      when /^News/
        selection = true
      when /^(Sponsors?|Events|Tools)/
        break if selection
      end
      if selection
        news += line
      end
    end
    issue       = Acetone::Issue.new
    issue.links = URI.extract(news)
    issue.save!
  end
end
