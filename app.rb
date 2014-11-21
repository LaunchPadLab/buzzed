require 'rubygems'
require 'bundler'
require "sinatra"
require "sinatra/reloader" if development?
require 'dotenv'
require 'twilio-ruby'
require 'hipchat'

Dotenv.load

Bundler.require

get '/' do
  send_to_hipchat
  redirect to('/say-hello')
end

def send_to_hipchat
  client = HipChat::Client.new(ENV['HIPCHAT_TOKEN'], :api_version => 'v2')
  room = 'huron-door'
  username = 'scottweisman'
  buzzed_url = 'https://huron-door.herokuapp.com/buzzed'
  client[room].send(username, "Someone is at the front door! <a href=#{buzzed_url}>Let 'em in!</a>", color: 'green', message_format: 'html')
end

get '/say-hello' do
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, and welcome to Launch Pad Lab.'
    r.Play '/such_great_heights.mp3'
  end.text
end

get '/buzzed' do
  client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
  calls = client.account.calls.list({:status => 'in-progress' })
  if calls.any?
    current_call = client.account.calls.get(calls.first.sid)
    current_call.update(:url => "https://huron-door.herokuapp.com/buzz.xml", :method => "GET")
    "BUZZED!"
  else
    "Something went wrong. Get off your ass and let them in."
  end
end

