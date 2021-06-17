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
  'channel'          => "#the_office",
  'name'             => "buzzer",
  'incoming_webhook' => ENV['INCOMING_WEBHOOK'],
  'outgoing_token'   => ENV['OUTGOING_TOKEN']
}

redis = Redis.new(:url => ENV['REDIS_URL'])

bot = Slackbotsy::Bot.new(config) do

  hear /^.open$/i do
    redis.set("door_status", "open")
    redis.expire("door_status", 30)
    "Buzzed!"
  end

  hear /^.stayopen$/i do
    redis.set("door_status", "auto")
    redis.expire("door_status", 3600)
    "The door will automatically buzz in for 1 hour. Type .close to close the door."
  end

  hear /^.close$/i do
    redis.expire("door_status", 0)
    "The door has been closed and will not automatically buzz in."
  end

end

# class Time
  # def is_weekday?
  #   [1,2,3,4,5].include?(wday)
  # end
# end

post '/' do
  # def office_open?
    # time = Time.now
    # time.is_weekday? && time.hour >= 9 && time.hour <= 17
  # end

  # if redis.get("door_status") == "auto"
  #   bot.post(channel: "#the_office", username: "buzzer", icon_emoji: ":door:", text: "Someone has been buzzed in.")
  #   content_type "text/xml"
  #   Twilio::TwiML::Response.new do |r|
  #     r.say(message: "Hello, and welcome to Launch Pad Lab.")
  #     r.play(digits: "wwww6")
  #   end.to_s
  # else
    bot.post(channel: "#the_office", username: "buzzer", icon_emoji: ":door:", text: "Someone is at the front door.\nType *.open* to let them in.")
    redirect to("/say-hello")
  # end
end

get '/say-hello' do
  content_type "text/xml"
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say(message: "Hello, and welcome to Launch Pad Lab.")
    r.play(url: "/such_great_heights.mp3")
  end.to_s
end

post '/door-status' do
  bot.handle_item(params)
end

post '/buzz-door' do
  client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
  calls = client.account.calls.list({ :status => "in-progress" })
  if calls.any?
    current_call = client.account.calls.get(calls.first.sid)
    current_call.update(:url => "https://buzzed-app.herokuapp.com/buzz.xml", :method => "GET")
  end
end

get '/stay-awake' do
  "Wake Up!"
end
