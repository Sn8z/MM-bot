require 'discordrb'
require 'open-uri'

bot = Discordrb::Bot.new token: ENV["DISCORD_SECRET"], client_id: ENV["DISCORD_CLIENT_ID"]

bot.message(with_text: '!help') do |event|
  event.respond 'Ring Poolia!'
end

bot.message(content: '!ping') do |event|
  m = event.respond('Pong!')
  m.edit "Pong! `Time taken: #{Time.now - event.timestamp} seconds.`"
end

bot.message(content: '!roll') do |event|
  event.respond("#{event.author.username} rolled #{rand(1..100)}!")
end

bot.message(content: '!chuck') do |event|
  chuck = JSON.parse(open("https://api.chucknorris.io/jokes/random").read)
  event.respond(chuck["value"])
end

bot.message(content: '!source') do |event|
  event.respond("https://github.com/Sn8z/MM-bot")
end

bot.message(content: '!steam') do |event|
  steamJSON = JSON.parse(open("https://steamgaug.es/api/v2").read)
  steam = "**Steam status:**\n"
  steam += "```Steam Client is #{getSteamStatus(steamJSON['ISteamClient']['online'])} \n"
  steam += "Steam Community is #{getSteamStatus(steamJSON['SteamCommunity']['online'])} \n"
  steam += "Steam Store is #{getSteamStatus(steamJSON['SteamStore']['online'])} \n"
  steam += "Steam User is #{getSteamStatus(steamJSON['ISteamUser']['online'])}```"
  event.respond(steam)
end

def getSteamStatus(code)
  if(code == 1)
    return "online"
  else
    return "offline"
  end
end

bot.run
