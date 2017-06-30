require 'discordrb'
require 'open-uri'

bot = Discordrb::Bot.new token: ENV["DISCORD_SECRET"], client_id: ENV["DISCORD_CLIENT_ID"]

bot.message(with_text: '!help') do |event|
  event.respond 'Ring Poolia!'
end

bot.message(content: 'Ping!') do |event|
  m = event.respond('Pong!')
  m.edit "Pong! Time taken: #{Time.now - event.timestamp} seconds."
end

bot.message(content: '!roll') do |event|
  event.respond("You rolled " + rand(1..100).to_s + "!")
end

bot.message(content: '!chuck') do |event|
  chuck = JSON.parse(open("https://api.chucknorris.io/jokes/random").read)
  event.respond(chuck["value"])
end

bot.run
