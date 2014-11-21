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

  response = Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, and welcome to Launch Pad Lab.', voice: 'alice'
  end

  # client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
  # call_sid = client.account.calls.list({:status => 'in-progress' }).first.sid

  client = HipChat::Client.new(ENV['HIPCHAT_TOKEN'], :api_version => 'v2')
  room = 'huron-door'
  username = 'scottweisman'
  buzzed_url = 'https://huron-door.herokuapp.com/buzzed'
  client[room].send(username, "Someone is at the front door! <a href=#{buzzed_url?call_sid}>Let 'em in!</a>", color: 'green', message_format: 'html')

end

get '/buzzed' do
  # @call = @client.account.calls.get("CAe1644a7eed5088b159577c5802d8be38")
  # @call.update(:url => "http://demo.twilio.com/docs/voice.xml",
  #     :method => "POST")
  response = Twilio::TwiML::Response.new do |r|
    r.Play digits: "www6"
  end

end

