require 'discordrb'
require 'wolfram'
require 'open-uri'

#Instantiate new CommandBot
bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_SECRET"], client_id: ENV["DISCORD_CLIENT_ID"], prefix: '!'

#print all entries to terminal
bot.message do |event|
  puts event.author.username + " --> " + event.content 
end

#respond to the user with a Pong! and the time it takes
bot.command :ping do |event|
  m = event.respond('Pong!')
  m.edit "Pong! `Time taken: #{Time.now - event.timestamp} seconds.`"
end

#roll a random number
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

#retrieve random Chuck Norris "fact"
bot.command :chuck do |event|
  chuck = JSON.parse(open("https://api.chucknorris.io/jokes/random").read)
  event.respond(chuck["value"])
end

#retrieve random yomomma joke
bot.command :mom do |event|
  mom = JSON.parse(open("http://api.yomomma.info").read)
  event.respond(mom["joke"])
end

#Access wolfram api
bot.command :wolfram do |event, *args|
  query = args.join(' ')
  result = Wolfram.fetch(query)
  hash = Wolfram::HashPresenter.new(result).to_hash
  if(hash[:pods].empty?)
    event.respond("No results")
  else
    hash[:pods].each do |key, value|
      if(!value[0].empty?)
        event << "**#{key}**"
        event << "#{value[0]}"
      end
    end
    return
  end
end

#Fetch random GIF from giphy based on word
bot.command(:gif, min_args: 0, max_args: 1) do |event, word|
  if word
    response = JSON.parse(open("https://api.giphy.com/v1/gifs/random?api_key=#{ENV["GIPHY_SECRET"]}&tag=#{word}").read)
  else
    response = JSON.parse(open("https://api.giphy.com/v1/gifs/random?api_key=#{ENV["GIPHY_SECRET"]}").read)
  end

  if response["data"].size > 0
    event.respond(response["data"]["image_url"])
  else
    event.respond("No relevant gif found :(")
  end
end

bot.command :sloth do |event|
  response = JSON.parse(open("https://api.giphy.com/v1/gifs/random?api_key=#{ENV["GIPHY_SECRET"]}&tag=sloth").read)
  event.respond(response["data"]["image_url"])
end

#Post Github repo url
bot.command :source do |event|
  event.respond("https://github.com/Sn8z/MM-bot")
end

#Post "Farstu" explanation
bot.command :farstu do |event|
  event.respond("https://sv.wikipedia.org/wiki/Farstu")
end

#Check the status of the different steam services
bot.command :steam do |event|
  steamJSON = JSON.parse(open("https://steamgaug.es/api/v2").read)
  steam = "**Steam status:**\n"
  steam += "```Steam Client is #{getSteamStatus(steamJSON['ISteamClient']['online'])} \n"
  steam += "Steam Community is #{getSteamStatus(steamJSON['SteamCommunity']['online'])} \n"
  steam += "Steam Store is #{getSteamStatus(steamJSON['SteamStore']['online'])} \n"
  steam += "Steam User is #{getSteamStatus(steamJSON['ISteamUser']['online'])}```"
  event.respond(steam)
end

#translate status code to string value
def getSteamStatus(code)
  if(code == 1)
    return "online"
  else
    return "offline"
  end
end

Wolfram.appid = ENV["WOLFRAM_SECRET"]
bot.run
