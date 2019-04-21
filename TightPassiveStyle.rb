require_relative 'PlayerStyle'
#Tight Passive (:tp)
#Plays high odds hands with a high bankroll or a low pot size. 
class TightPassiveStyle < PlayerStyle
	def decide
		if @odds >= @base_odds && (@initial_bankroll >= (@initial_bankroll*0.90) || @pot_size <= @starting_chip)
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
