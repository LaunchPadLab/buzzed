require 'rubygems'
require 'bundler'
require 'dotenv'
Dotenv.load

Bundler.require

get '/' do
  "Welcome to the Huron Door."
  # send hipchat API request - msg to LPL room with link to let them in
  # Play welcome message for visitor
  # buzz in link is clicked in hipchat
end

