require "./app.rb"

run Rack::URLMap.new({
  "/" => Public,
  "/receiver" => Protected
})
