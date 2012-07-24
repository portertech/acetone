require File.join(File.dirname(__FILE__), "mongohq")

module Acetone
  USER_ATTRIBUTES = [
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
      Hash[USER_ATTRIBUTES.map { |attribute| [attribute, send(attribute)] }]
    end

    def load(user_id)
      begin
        document = mongohq.collection("users").find_one(:user_id => user_id)
        USER_ATTRIBUTES.each do |attribute|
          send("#{attribute}=".to_sym, document[attribute.to_s])
        end
        true
      rescue
        false
      end
    end

    def valid?
      @created.is_a?(Integer) && @user_id.is_a?(Integer) &&
        @oauth_token.is_a?(String) && @oauth_token_secret.is_a?(String)
    end

    def save!
      if valid?
        mongohq.collection("users").update({"user_id" => @user_id}, to_hash, :upsert => true)
        true
      else
        false
      end
    end

    def delete!
      if valid?
        mongohq.collection("users").remove(:user_id => @user_id)
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
