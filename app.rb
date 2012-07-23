require "sinatra"
require "json"
require File.join(File.dirname(__FILE__), "lib", "issue")
require File.join(File.dirname(__FILE__), "lib", "user")

get "/" do
  "Hello world!"
end

get "/latest" do
  content_type "application/json"
  issue = Acetone::Issue.new
  issue.latest!
  JSON.generate(issue.to_hash)
end

post "/user" do
  request.body.rewind
  data = JSON.parse(request.body.read)
  puts data.inspect
end
