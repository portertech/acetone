require "sinatra"
require "json"
require File.join(File.dirname(__FILE__), "lib", "issue")

get "/" do
  "Hello world!"
end

get "/latest" do
  content_type "application/json"
  latest = Acetone::Issue.new.latest.reject {|key, value| key == "_id" }
  JSON.generate(latest)
end
