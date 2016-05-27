# Buzzed

Control your office's callbox buzzer from Slack.

At [LaunchPad Lab](http://launchpadlab.com), we programmed our office's callbox to use a Twilio number, allowing us to buzz guests in using Slack.

Here's how we did it:

1. First we got a Twilio number. We had our property manager program our callbox to call our Twilio number each time someone buzzed us.
2. Our Twilio number is set to post to the URL of a small Sinatra app we developed. The code is here: https://github.com/LaunchPadLab/buzzed
3. We wanted our guest to know that someone had answered the line. So, the Sinatra app first uses a TwiML response that says "Hello, and welcome to LaunchPad Lab." After that it starts playing Such Great Heights by the Postal Service, of course.
4. The Sinatra app posts to our Slack channel saying that someone is at the door and prompting people in the room to type ".open" to open the door.
5. If someone types .open, a Slack webhook is fired. Via Twilio's API we get the in progress call and send it an XML file that digitally presses the button to buzz the person in.
6. At this point, our visitor comes up to our office for a beer and our Sintra app takes a much needed break.

## Getting Started

1. Clone this repository
2. Get a Twilio number
3. Ask your building manager to add your Twilio number to your office callbox.
4. Add your environment variables for Twilio and Slack to a file called .env in the root directory of this app.
5.

Run the server locally

    rackup

Redis

    heroku redis:cli