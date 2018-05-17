require 'bundler'

Bundler.require

#mdels
dirs = ["models"]
dirs.each do |dir|
  Dir["#{dir}/*.rb"].each {|file| require_relative file}
end

require_relative 'pool.rb'
require_relative 'sfbio.rb'

use Rack::MethodOverride

ConnectionPool.instance.create(5) do
  SQLite3::Database.open('db/LoginSystem.sqlite')
end

run SFBio
