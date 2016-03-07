require 'rubygems'
require 'bundler'
require "sinatra"
require "sinatra/reloader" if development?
require 'dotenv'
require 'twilio-ruby'
require 'slackbotsy'
require 'open-uri'

Dotenv.load

Bundler.require

config = {
  'channel'          => '#launchpad-lab',
  'name'             => 'buzzer',
  'incoming_webhook' => ENV['INCOMING_WEBHOOK'],
  'outgoing_token'   => ENV['OUTGOING_TOKEN']
}

bot = Slackbotsy::Bot.new(config) do

  hear /.open/i do
    "Buzzed!"
  end

  hear /.stayopen/i do
    "The door will automatically buzz up for an hour"
  end

end

post '/' do
  if Time.now < cookies[:expire_time]
    redirect to('/buzz-door')
  else
    bot.post(channel: '#launchpad-lab', username: 'buzzer', icon_emoji: ':satellite:', text: "Someone is at the front door.\nType *.open* to let them in.")
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

get '/stay-open' do
  expire_time = Time.now + 3600  # 1 hour
  cookies[:expire_time] = expire_time
end

get '/stay-awake' do
  "Wake Up!"
end
