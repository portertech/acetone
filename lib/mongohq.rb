require "mongo"
require "uri"

module Acetone
  class MongoHQ
    def mongohq
      return @mongohq if @mongohq
      db       = URI.parse(ENV["MONGOHQ_URL"])
      db_name  = db.path.gsub(/^\//, "")
      @mongohq = Mongo::Connection.new(db.host, db.port).db(db_name)
      @mongohq.authenticate(db.user, db.password)
      @mongohq
    end
  end
end
