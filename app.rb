require 'rubygems'
require 'bundler'
require "sinatra"
require "sinatra/reloader" if development?
require 'dotenv'
require 'twilio-ruby'
require 'slackbotsy'
require 'open-uri'
require "redis"

Dotenv.load

Bundler.require

config = {
  'channel'          => '#launchpad-lab',
  'name'             => 'buzzer',
  'incoming_webhook' => ENV['INCOMING_WEBHOOK'],
  'outgoing_token'   => ENV['OUTGOING_TOKEN']
}

redis = Redis.new(:url => ENV['REDIS_URL'])

bot = Slackbotsy::Bot.new(config) do

  hear /.open/i do
    "Buzzed!"
  end

  hear /.stayopen/i do
    "The door will automatically buzz in for an hour."
    # redis.set("door_open", "auto")
    # redis.expire("door_open", 3600)
    # bot.post(channel: '#launchpad-lab', username: 'buzzer', icon_emoji: ':door:', text: "The door will automatically buzz in for an hour.")
  end

end

post '/' do
  if redis.get("door_open")
    bot.post(channel: '#launchpad-lab', username: 'buzzer', icon_emoji: ':door:', text: "Someone has been buzzed in.")
    redirect to('/buzz-door')
  else
    bot.post(channel: '#launchpad-lab', username: 'buzzer', icon_emoji: ':door:', text: "Someone is at the front door.\nType *.open* to let them in.")
    redirect to('/say-hello')
  end
end

get '/say-hello' do
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello, and welcome to Launch Pad Lab.'
    r.Play '/such_great_heights.mp3'
  end.text
end

post '/open' do
  bot.handle_item(params)
end

post '/buzz-door' do
  client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
  calls = client.account.calls.list({ :status => 'in-progress' })
  if calls.any?
    current_call = client.account.calls.get(calls.first.sid)
    current_call.update(:url => "https://buzzed-app.herokuapp.com/buzz.xml", :method => "GET")
  end
end

get '/stay-awake' do
  "Wake Up!"
end
