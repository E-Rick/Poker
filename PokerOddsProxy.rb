require_relative 'APIProxy'
require 'open-uri'
class PokerOddsProxy < APIProxy
	
	def initialize(url)
		@url = url
	end

	def createObject
		@odds = @object['odds']
		@cards = @object['cards']
	end

	def makeURL(cards, board, num_players)
		uri = URI(@url)
		uri.query = "cards=#{cards.join}&board=#{board.join}&num_players=#{num_players}"
		@url = uri.to_s
	end

	def getOdds(cards, players, board)
		begin
			self.makeURL(cards, players, board)
			self.makeRequest
			self.createObject
		rescue => e
			puts "******Error getting odds from API****"	
			@odds = Kernel.rand	
		end
		@odds
	end

	def getWinners(cards,players,board)
		begin
			self.makeURL(cards,board,players)
			self.makeRequest
			self.createObject
		rescue => e
			puts "******Error getting winner from API****"
			winners = cards.join
			@cards = winners[0,4]
		end
		@cards
	end
end
