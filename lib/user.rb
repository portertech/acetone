require File.join(File.dirname(__FILE__), "mongohq")

module Acetone
  USER_ATTRIBUTES = [
    :_id,
    :created,
    :user_id,
    :oauth_token,
    :oauth_token_secret,
    :last_issue
  ]

  class User < MongoHQ
    attr_accessor *USER_ATTRIBUTES

    def initialize
      @created = Time.now.to_i
    end

    def to_hash
      {
        :created            => @created,
        :user_id            => @user_id,
        :oauth_token        => @oauth_token,
        :oauth_token_secret => @oauth_token_secret,
        :last_issue         => @last_issue
      }
    end

    def valid?
      @created.is_a?(Integer) && @user_id.is_a?(Integer) &&
        @oauth_token.is_a?(String) && @oauth_token_secret.is_a?(String)
    end

    def save!
      if valid?
        if @_id
          mongohq.collection("users").update({"_id" => @_id}, to_hash)
        else
          mongohq.collection("users").insert(to_hash)
        end
        true
      else
        false
      end
    end
  end

  class Users < MongoHQ
    def all
      mongohq.collection("users").find.map do |document|
        user = User.new
        USER_ATTRIBUTES.each do |attribute|
          user.send("#{attribute}=".to_sym, document[attribute.to_s])
        end
        user
      end
    end
  end
end
