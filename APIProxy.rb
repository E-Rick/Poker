require 'open-uri'
require 'json'
class APIProxy
 	
	def createObject
		raise NoMethodError	
	end

	def makeRequest
		@object = JSON.parse(open(@url).read)
	end
end
