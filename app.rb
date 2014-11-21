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
    r.Say 'Hello, and welcome to Launch Pad Lab.', voice: 'alice'
    r.Enqueue
    end
  end.text
end

get '/buzzed' do
  client = Twilio::REST::Client.new ENV['TWILIO_TOKEN'], ENV['TWILIO_TOKEN']
  call = client.account.calls.list({:status => 'queued' }).first.sid
  call.update(:url => "http://demo.twilio.com/docs/buzz.xml", :method => "GET")
end

