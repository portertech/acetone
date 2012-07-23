require File.join(File.dirname(__FILE__), "mongohq")

module Acetone
  class User < MongoHQ
    attr_accessor :created, :user_id, :access_token, :last_issue

    def initialize
      @created = Time.now.to_i
    end

    def to_hash
      {
        :created      => @created,
        :user_id      => @user_id,
        :access_token => @access_token,
        :last_issue   => @last_issue
      }
    end

    def valid?
      @created.is_a?(Integer) && @user_id.is_a?(Integer) &&
        @access_token.is_a?(String) && !@access_token.empty?
    end

    def save!
      if valid?
        mongohq.collection("users").insert(to_hash)
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
        %w[created user_id access_token last_issue].each do |attribute|
          user.send("#{attribute}=".to_sym, document[attribute])
        end
        user
      end
    end
  end
end
