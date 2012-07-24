require "instapaper"

module Acetone
  class Instapaper
    def initialize
      ::Instapaper.configure do |config|
        config.consumer_key    = ENV["ACETONE_INSTAPAPER_KEY"]
        config.consumer_secret = ENV["ACETONE_INSTAPAPER_SECRET"]
      end
    end

    def use_access_token(oauth_token, oauth_token_secret)
      ::Instapaper.oauth_token        = oauth_token
      ::Instapaper.oauth_token_secret = oauth_token_secret
      true
    end

    def current_access_token
      {
        :oauth_token        => ::Instapaper.oauth_token,
        :oauth_token_secret => ::Instapaper.oauth_token_secret
      }
    end

    def get_access_token(username, password)
      begin
        token = ::Instapaper.access_token(username, password)
        use_access_token(token["oauth_token"], token["oauth_token_secret"])
      rescue
        false
      end
    end

    def current_credentials
      begin
        credentials = ::Instapaper.verify_credentials
        if credentials.is_a?(Array)
          current_access_token.merge(:user_id => credentials.first.user_id)
        else
          false
        end
      rescue
        false
      end
    end

    def valid_credentials?
      current_credentials
    end

    def read_later(link)
      ::Instapaper.add_bookmark(link)
    end
  end
end
