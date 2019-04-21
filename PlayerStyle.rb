class PlayerStyle
	attr_accessor :odds, :pot_size, :starting_chip, :bankroll, :base_odds, :bet_made
	def initialize(bankroll,num_player)
		@bet_made = false
		@initial_bankroll = bankroll
		@base_odds = 1.0/num_player * 2
	end

	def base_odds=(players_left)
		@base_odds = 1.0/players_left * 2
	end
end
