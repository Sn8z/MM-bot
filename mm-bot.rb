require 'discordrb'
require 'wolfram'
require 'open-uri'

#Instantiate new CommandBot
bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_SECRET"], client_id: ENV["DISCORD_CLIENT_ID"], prefix: '!'

#create stats file if it doesn't exists
if(!File.exists?("stats.json"))
  File.open("stats.json", "w") {|file| file.write('{"words": {}, "users": {}}')}
end

#fetch stats from json file
def getStats
  JSON.parse(File.read("stats.json"))
end

#Track statistics
bot.message do |event|
  cmd = event.content.downcase.gsub(/[^a-z0-9\s]/i, "").split(" ")[0]
  stats = getStats()
  if(!stats["words"].key?(cmd))
    stats["words"][cmd] = {"amount" => 1}
  else
    stats["words"][cmd]["amount"] += 1
  end

  user = event.author.username
  if(!stats["users"].key?(user))
    stats["users"][user] = {"amount" => 1}
  else
    stats["users"][user]["amount"] += 1
  end

  File.open("stats.json", "w") { |file| file.write(JSON.generate(stats)) }
end

#Print relevant stats
bot.command :stats do |event|
  event << '**Statistics**'
  event << '**Commands:**'
  getStats["words"].each do |key,value|
    event << "**#{key}:** #{value["amount"]}"
  end
  event << "\n"
  event << '**Bot usage:**'
  getStats["users"].each do |key,value|
    event << "**#{key}:** #{value["amount"]}"
  end

  return
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
  event.respond(response["data"]["image_url"])
end

bot.command :sloth do |event|
  response = JSON.parse(open("https://api.giphy.com/v1/gifs/random?api_key=#{ENV["GIPHY_SECRET"]}&tag=sloth").read)
  event.respond(response["data"]["image_url"])
end

#Post Github repo url
bot.command :source do |event|
  event.respond("https://github.com/Sn8z/MM-bot")
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
