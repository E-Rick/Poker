#Encapsulates the Database functionality, such reading in the JSON file, writing the JSON file. Updating the database objects.
require 'json'

class Database

	def initialize(players)
		@players = players
		@file = File.open("database_players.json","w")
	end

	def generateDatabase(games_played)
		user_hash = []
		@players.each do |player|
			user_hash << {
				"name" => "#{player.name}",
				"folds" => "#{player.folds}",
				"losses" => "#{player.losses}",
				"wins" => "#{player.wins}",
				"games_played" => "#{games_played}"
			}
			File.open("database_players.json","w") do |f|
				f.write(JSON.pretty_generate(user_hash))
			end
		end 
	end

end
