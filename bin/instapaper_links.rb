#!/usr/bin/env ruby

cwd = File.expand_path(File.dirname(__FILE__))

require File.join(cwd, "..", "lib", "issue")
require File.join(cwd, "..", "lib", "user")
require File.join(cwd, "..", "lib", "instapaper")

issue = Acetone::Issue.new
issue.latest!

users = Acetone::Users.new

instapaper = Acetone::Instapaper.new

users.all.each do |user|
  if user.valid? && (user.last_issue || 0) < issue.created
    instapaper.use_access_token(user.oauth_token, user.oauth_token_secret)
    if instapaper.valid_credentials?
      issue.links.each do |link|
        instapaper.read_later(link)
      end
      user.last_issue = issue.created
      user.save!
    end
  end
end
