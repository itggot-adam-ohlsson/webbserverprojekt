require 'bundler'

Bundler.require

#mdels
dirs = ["sinatra", "models"]
dirs.each do |dir|
  Dir["#{dir}/*.rb"].each {|file| require_relative file}
end

require_relative 'login.rb'

use Rack::MethodOverride

run SFBio
