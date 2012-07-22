require File.join(File.dirname(__FILE__), "mongohq")

module Acetone
  class Issue < MongoHQ
    attr_accessor :created, :links

    def initialize
      @created = Time.now.to_i
      @links   = []
      super
    end

    def valid?
      @created.is_a?(Integer) && @links.is_a?(Array) && !@links.empty?
    end

    def save
      if valid?
        issue = {
          :created => @created,
          :links   => @links
        }
        @mongohq.collection("issues").insert(issue)
        true
      else
        false
      end
    end

    def latest
      @mongohq.collection("issues").find.sort([:created, :desc]).first
    end
  end
end
