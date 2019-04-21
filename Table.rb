require_relative 'Deck'
#An aggregate class that contains up to 8 players.
#Should also keep track of who is dealing, the current pot, who is in the game, who has folded, etc.
#Should use the Enumerable Module to iterate through the Players
class Table
	include Enumerable
	attr_accessor :players, :dealer, :deck, :board, :pot_size, :current_players, :folded
	
	def initialize
		@players, @folded, @current_players, @board = [], [], [], []
		@pot_size = 0
	end

	def each(&block)
		@current_players.each(&block)
	end

	def makeDeck
		@deck = Deck.new
		@deck.shuffle!
	end
	
	def reset
		puts "These players folded: #{@folded}"
		self.each {|player| puts "#{player.to_s}"}
		@folded.clear
	end

	def printPlayers
		p @current_players
	end

	def bet(amount, player)
		@pot_size += amount
		player.withdraw(amount)
	end
	
	def fold(player)
		@folded << player
	end
	
	def removeFolded
		@folded.each {|player |@current_players.delete(player)}
		@current_players.sort
		#self.each {|player| puts "#{player.to_s}"}
	end

	def [](index)
		@current_players[index]
	end

	def <<(player)
		@players << player
		@current_players << player
	end

	def length
		@current_players.length
	end
	
end


