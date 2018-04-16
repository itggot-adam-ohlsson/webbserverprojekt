require 'bundler'

Bundler.require

#mdels
dirs = ["sinatra", "models"]
dirs.each do |dir|
  Dir["#{dir}/*.rb"].each {|file| require_relative file}
end

require_relative 'pool.rb'
require_relative 'login.rb'

use Rack::MethodOverride

ConnectionPool.instance.create(5) do
  SQLite3::Database.open('db/LoginSystem.sqlite')
end

run SFBio
