require "sinatra"
require "json"
require File.join(File.dirname(__FILE__), "lib", "issue")
require File.join(File.dirname(__FILE__), "lib", "user")
require File.join(File.dirname(__FILE__), "lib", "instapaper")

get "/" do
  "Hello world!"
end

get "/latest" do
  content_type "application/json"
  issue = Acetone::Issue.new
  issue.latest!
  body JSON.generate(issue.to_hash)
end

post "/user" do
  request.body.rewind
  data = JSON.parse(request.body.read)
  valid = %w[username password latest_issue].all? do |key|
    data.has_key?(key)
  end
  if valid
    instapaper = Acetone::Instapaper.new
    if instapaper.get_access_token(data["username"], data["password"])
      if credentials = instapaper.current_credentials
        user = Acetone::User.new
        user.user_id            = credentials[:user_id]
        user.oauth_token        = credentials[:oauth_token]
        user.oauth_token_secret = credentials[:oauth_token_secret]
        unless data["latest_issue"]
          issue = Acetone::Issue.new
          issue.latest!
          user.last_issue = issue.created
        end
        if user.save!
          body ""
        else
          status 500
          body ""
        end
      else
        status 401
        body ""
      end
    else
      status 401
      body ""
    end
  else
    status 400
    body ""
  end
end
