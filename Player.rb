require_relative 'UserDataProxy'
require_relative 'Deck'
require_relative 'Card'
#Contains player’s name, cards, and bankroll
#You may use this class for the user player or create another class if you wish
class Player
	attr_accessor :name, :cards, :bankroll, :odds, :chips, :turn, :style, :wins, :losses, :folds
	
	#API url to generate random user data
	URL = 'https://randomuser.me/api/?inc=name&noinfo'
	URL_ODDS = 'http://stevenamoore.me/projects/holdemapi'

	def initialize(starting_chips, turn)
		@turn = turn
		@cards = []
		@folds = @wins = @losses = 0
		@dealer = false
		@chips = starting_chips
		proxy = UserDataProxy.new(URL)
		@name = proxy.getInfo
	end

	def <<(card)
		@cards << card
	end

	def withdraw(amount)
		@chips -= amount
		@bankroll -= amount
	end

	def deposit(amount)
		@chips += amount
		@bankroll += amount	
	end

	def evaluateOdds(board,num_players)
		proxy = PokerOddsProxy.new(URL_ODDS)
		@odds = proxy.getOdds(@cards,board,num_players)
	end

	def to_s
		string = "Name: #{@name} | Cards: #{@cards.join(" ")} | bankroll: #{@bankroll} | chips: #{@chips}| odds: #{@odds} | turn: #{@turn}" 
	end

	def <=>(other)
		@turn <=> other.turn
	end

end
