require_relative 'Card'
#An aggregate class that contains 52 cards at the start of each game.
#The cards should be shuffled before each game.
#Should use the Enumerable Module to iterate through the deck
class Deck
	include Enumerable
	attr_reader :cards

	def initialize
		@cards = []
		ranks = %w{A 2 3 4 5 6 7 8 9 T J Q K}
		suits = %w{s h d c}
		suits.each do |suit|
			ranks.each_with_index do |rank,i|
				@cards << Card.new(rank, suit).to_s
			end
		end
	end

	def each(&block)
		@cards.each(&block)
	end
	
	def shuffle!
		@cards.shuffle!
	end
	
	#Draws a certain number of cards from top of deck and returns an array
	def draw
		@cards.pop
	end

	def remaining
		@cards.length
	end
end
