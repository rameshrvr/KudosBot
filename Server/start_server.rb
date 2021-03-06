require 'slack'
require_relative '../App/kudosbot'

# API token
@token = ENV['SLACK_API_TOKEN']

# Create a new realtime client
client = Slack::RealTime::Client.new(token: @token)
# create object for bot
bot = KudosBot.new(token: @token)

# Start the realtime server
client.on :hello do
  puts "Successfully connected, to the team at https://#{client.team.domain}.slack.com."
end

# Deals with realtime messages
client.on :message do |data|
  if data.text =~ /^kudos .*/i
    case data.text
    when /kudos help/i then
      bot.post_help_message(data: data)
    when /kudos stats/i then
      bot.post_stats_message(data: data)
    when /kudos leaderboard/i then
      bot.post_leaderboard_message(data: data)
    when /kudos giverboard/i then
      bot.post_giverboard_message(data: data)
    when /kudos &lt;.*&gt;/i then
      bot.post_kudos_message(data: data)
    end
  end
end

# Log a message when client is disconnected
client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
