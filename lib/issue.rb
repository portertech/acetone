require File.join(File.dirname(__FILE__), "mongohq")

module Acetone
  class Issue < MongoHQ
    attr_accessor :created, :links

    def initialize
      @created = Time.now.to_i
      @links   = []
    end

    def to_hash
      {
        :created => @created,
        :links   => @links
      }
    end

    def latest!
      document = mongohq.collection("issues").find_one(nil, :sort => [:created, :desc])
      @created = document["created"]
      @links   = document["links"]
    end

    def valid?
      @created.is_a?(Integer) && @links.is_a?(Array) && !@links.empty?
    end

    def save!
      if valid?
        mongohq.collection("issues").insert(to_hash)
        true
      else
        false
      end
    end
  end
end
