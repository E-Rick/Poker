require_relative 'PlayerStyle'
#Loose Aggressive
#Plays low odds hands with a low bankroll or a low pot size. 
class LooseAgressiveStyle < PlayerStyle
	def decide
		if @odds <= @base_odds && (@initial_bankroll <= (@initial_bankroll*0.90) || @pot_size <= @starting_chip)
		choice = rand(0..1)
			if @bet_made		
				return "call"
			end
			if !@bet_made && choice == 0
				return "check"
			else 
				return "bet"
			end
		else
			if !@bet_made
				return "check"
			else		
				return "fold"
			end
		end
	end

end
