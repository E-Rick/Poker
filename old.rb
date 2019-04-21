require_relative 'Player'
require_relative 'PokerOddsProxy'
require_relative 'Table'
require_relative 'TightAgressiveStyle'
require_relative 'TightPassiveStyle'
require_relative 'LoosePassiveStyle'
require_relative 'LooseAgressiveStyle'
require_relative 'Database'

BANKROLL = 500
MIN_CHIP = 50
MAX_CHIP = 200
URL_ODDS = 'http://stevenamoore.me/projects/holdemapi'

def main
#1 -- Initialize
	puts "-----------------------------------------------"
	puts "         Welcome to Texas Holdem Poker"
	puts "-----------------------------------------------"
	@hand_finished = false #hand has determined a winner
	@table = Table.new
	@choice = ''
	@games_played = 1

#2 -- Choose starting chip amount & amount of players
	puts "How many players (2-8) should sit at the table?"
	print"--> "
	@num_players = gets.chomp.to_i
	while !@num_players.between?(2,8)
		print "--> "
		@num_players = gets.chomp.to_i
	end

	puts "What is the starting chip amount?(50-200)"
	print"--> "
	@starting_chip = gets.chomp.to_i
	while !@starting_chip.between?(MIN_CHIP,MAX_CHIP)
		print "-->"
		@starting_chip = gets.chomp.to_i
	end

#3 -- Make players
	#1 -- Get user name
	puts "What is your name?"
	print"--> "
	name = gets.chomp
	printLine

	#2 -- Make User player and add him to table
	@user = Player.new(@starting_chip, 0)
	@user.bankroll = BANKROLL
	@user.name = name

	@table << @user
	puts "#{name} joined the table!"
	
	#3 -- Make Computer players, add them to table, choose their style
	turn = 0
	(@num_players-1).times do
		player = Player.new(@starting_chip, turn)
		player.bankroll = BANKROLL

		@table << player
		puts "#{player.name} joined the table! "
		turn += 1

		random_style = rand(0..3)
		if random_style == 0
			player.style = TightAgressiveStyle.new(BANKROLL, @num_players)
		elsif random_style == 1
			player.style = TightPassiveStyle.new(BANKROLL, @num_players)
		elsif random_style == 2	
			player.style = LooseAgressiveStyle.new(BANKROLL, @num_players)
		elsif random_style == 3
			player.style = LoosePassiveStyle.new(BANKROLL, @num_players)
		end
	end

#4 -- Choose a dealer
	printLine
	puts "Time to choose the dealer!"
	
	@new_game = false
	@dealer_index = rand(0..(@num_players-1))
	@dealer = @table[@dealer_index]

#5 -- Set player turn order (person to left of dealer goes first), sort array
	index = @dealer_index + 1 # index of player that goes first
	turn = 0 #Position as turn number
	begin
		index = 0 if index == @num_players
		@table[index].turn = turn
		index += 1
		turn += 1
	end until index == @dealer_index + 1

	sortPlayers

	puts "The dealer is: #{@dealer.name}!"
	printLine
	
	@database = Database.new(@table.players)
	@database.generateDatabase(@games_played)

#6 -- Start game
	while !@hand_finished
		@betting_round = 0

	#1 -- Iterate dealer if this is a new hand (new game)
		if @new_game
			printLine
			puts "		STARTING NEW HAND"
			printLine

			#reset table and clear array of folded
			@table.pot_size = 0
			@table.board.clear
			@table.folded.clear
			@games_played += 1

			@table.current_players = @table.players 			
			
			#@table.each do |player| player.cards.clear}

			#dealer should be the person who went first last game so table[0]

			@table.each_with_index do |player, index|
				player.cards.clear
				player.turn = index - 1
				player.turn = @num_players - 1 if player.turn == -1
				puts "#{player.name} turn is now: #{player.turn}"
			end
			
			sortPlayers

			#@table.each{|player| puts "#{player.name} turn is now: #{player.turn}"}

			#set new dealer's turn to last position
			@dealer_index = @num_players - 1	
		
			@new_game = false
			printLine

		end

	#3 -- Make and shuffle deck
		puts "Dealer is shuffling the deck..."
		@table.makeDeck

	#6 -- Preflop (Send out hole cards) (1st betting round)
		puts "Dealer is dealing the hole cards..."
		2.times { @table.each {|player| player.cards << @table.deck.draw} }

		evaluateOdds
		
		printLine
		@table.each {|player| puts "#{player.name} #{player.turn} recieved: #{player.cards.join(' ')} | odds: #{player.odds}"}

		@betting_round += 1
		beginBetting
		if @hand_finished
			if continue?
				redo
			else
				break
			end
		end

	#7 -- Flop (Deal 3 cards to board & begin betting)
		printLine
		deal(3,'Flop')
		beginBetting
		if @hand_finished
			if continue?
				redo
			else
				break
			end
		end
	
	#8 -- Turn (Draw another card from deck)
		printLine
		deal(1,'Turn')
		beginBetting
		if @hand_finished
			if continue?
				redo
			else
				break
			end
		end
		
	#9 -- River (Draw another card from deck)
		printLine
		deal(1,'River')
		beginBetting
		if @hand_finished
			if continue?
				redo
			else
				break
			end
		end
	#10 -- GameOver (Ask user to continue)
	end
	printLine
	puts "		STATISTICS"
	printLine
	@database.generateDatabase(@games_played)
	object = JSON.parse(File.read("database_players.json"))
	puts object
	printLine
	puts "Thanks for playing Texas Holdem Poker!"
	
end

#Computers the bets for computer and user
def startBetting
	#1 -- Tell user their odds
	getUserOdds
	@new_round = true #Flag for user to determine if its a new round
	@bet_made = false
	user_bet = false
	loop = 0
	bet = 0
	
	begin 
		loop += 1
		@table.each_with_index do |player, index|
		#-- Calculate computer decisions

			#Check table
			if @table.length == 1
				printLine
				puts "Everyone has folded!" 
				puts "Congratulations #{player.name} you won $#{@table.pot_size}!"
				player.deposit(@table.pot_size)
				@hand_finished = true
				return
			end


			# -- Compute Computer decision
			if player != @user
				#Fill style requirements to decide
				player.style.odds = player.odds
				player.style.starting_chip = @starting_chip
				player.style.bankroll = player.bankroll
				player.style.pot_size = @table.pot_size
				player.style.bet_made = true if @bet_made
				player.style.bet_made = false if !@bet_made

				@decision = player.style.decide
				if @decision == "bet"
					puts "#{player.name} bet $2!"
					@table.bet(2,player)
					@bet_made = true
				elsif @decision == "fold"
					puts "#{player.name} folded!"
					@table.fold(player)
					player.folds += 1
					break if index == @num_players - 1
				elsif @decision == "check"
					puts "#{player.name} checked!"
					puts index
					break if index == @num_players - 1
				elsif @decision == "call"
					puts "#{player.name} called!"
					@table.bet(2,player)
					if index == @table.length - 1 && loop == 2
						break
					end
				end
			# -- Compute User decision if user hasn't folded
			elsif !@table.folded.include? @user
				# 2 -- Ask for User input
				puts ""
				if @table.pot_size == 0 || new_round
					puts "Your turn! Would you like to check, bet or fold?" 
				elsif user_bet
					puts "Your turn! Would you like to check or fold?"
				else 
					puts "Your turn! Would you like to call or fold?"
				end
				print"--> "
				@choice = gets.chomp
				if @choice.include? 'bet' 
					@table.bet(2,player)
					@bet_made = true
					user_bet = true
					puts "#{player.name} bet $2"
				elsif @choice.include? 'fold'
					puts ""
					puts "#{player.name} folded!"
					@table.fold(player)
					player.folds += 1
				elsif @choice.include? 'check' 
					puts "#{player.name} checked!"
					break if index == @table.length - 1
				elsif @choice.include? 'call'
					@table.bet(2,player) 
					puts "#{player.name} called!"
					if index == @table.length - 1 && loop == 2
						break
					end
				end
			end
			
			#Evaluate if round should continue after full loop
			if index == @table.length - 1 && loop == 1
				loop += 1
				if @choice.include? 'bet'
					startBetting
				elsif @choice.include? 'call' 
					break
				elsif @decision.include? 'bet'
					startBetting
				end
			end
		end
	end until loop == 2 
	
	#If River hand and 
	if @betting_round == 4
		#2 -- Showdown
		printLine
		puts "    	       SHOWDOWN ROUND!"
		printLine

		#1 -- Call API to get winning hand 
		proxy = PokerOddsProxy.new(URL_ODDS)
		hand = []
		@table.each {|player| hand += player.cards}
		winners = proxy.getWinners(hand,@table.length,@table.board)
		winner = winners[0,4]

		@table.each do |player|
			player.losses += 1 
			if winner == player.cards.join
				puts "Congratulations #{player.name} you won $#{@table.pot_size}!" 
				player.deposit(@table.pot_size)
				player.wins += 1
				player.losses -= 1
			end		
			@hand_finished = true	
		end
	end	

	@table.removeFolded
	printLine
	puts "Pot Total = $#{@table.pot_size}"
	
end

#Deals out a number of cards to the board
def deal(draw_amount, round)
	@betting_round += 1
	puts "Dealer is dealing the #{round}..."
	draw_amount.times {@table.board << @table.deck.draw}
	puts "Cards on the board: #{@table.board.join(' ')}"
end

#Determines if user want's to play another game?
#Returns boolean true if no & false if yes (i would like to play another game)
def continue?
	printLine
	puts "Would you like to play another game? (yes or no)"
	print "--> "
	@choice = gets.chomp
	#If user doesn't want to continue hand is still finished
	if @choice.include? "yes"
		@new_game = true
		@hand_finished = false
		return true
	else 
		return false
	end
end

#Starts a new round of texas hold em poker
#Iterates the next dealer, 
def restartGame
	
end
	
#Template mathod for starting betting rounds
def beginBetting
	printLine
	startBetRound
	printLine
	startBetting
	@new_round = false
end


#Sort the current players by turn
#Copy the sorted array of current players to keep track of turns
def sortPlayers
	@table.current_players = @table.sort
	@table.players = @table.current_players.dup
end

def getUserOdds
	evaluateOdds
	@table.each {|player| puts "Your pokerhand's odds: #{player.odds} "if player.name == @user.name}
	printLine
end

def evaluateOdds 
	@table.each {|player| player.evaluateOdds(@table.board, @table.current_players)}
end

def printLine
	puts "-----------------------------------------------"
end

def nextRound
	puts "			NEXT ROUND		     "
end

def startBetRound
	puts "	     STARTING BETTING ROUND #{@betting_round}"
end

main

	
