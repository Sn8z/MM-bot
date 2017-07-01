require 'discordrb'
require 'wolfram'
require 'open-uri'

bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_SECRET"], client_id: ENV["DISCORD_CLIENT_ID"], prefix: '!'

bot.message(with_text: '!help') do |event|
  event.respond 'Ring Poolia!'
end

bot.command :ping do |event|
  m = event.respond('Pong!')
  m.edit "Pong! `Time taken: #{Time.now - event.timestamp} seconds.`"
end

bot.command(:roll, min_args: 0, max_args: 2, usage: 'roll [min/max] [max]') do |event, min, max|
  if max
    number = rand(min.to_i..max.to_i)
  elsif min
    number = rand(1..min.to_i)
  else
    number = rand(1..100)
  end
  event.respond("#{event.author.username} rolled **#{number}**")
end

bot.command :chuck do |event|
  chuck = JSON.parse(open("https://api.chucknorris.io/jokes/random").read)
  event.respond(chuck["value"])
end

bot.command :mom do |event|
  mom = JSON.parse(open("http://api.yomomma.info").read)
  event.respond(mom["joke"])
end

bot.command :wolfram do |event, *args|
  query = args.join('+')
  event.respond(open("http://api.wolframalpha.com/v1/result?appid=#{ENV["WOLFRAM_SECRET"]}&i=#{query}").read)
end

bot.command :source do |event|
  event.respond("https://github.com/Sn8z/MM-bot")
end

bot.command :steam do |event|
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
