#Contains the card’s suit and value
class Card

	attr_accessor :suit, :rank 

	def initialize(rank, suit)
		@suit = suit
		@rank = rank
	end

	def <=>(value)
		rank <=> other.rank
	end

	def to_s
		"#{rank}#{suit}"	
	end
end
