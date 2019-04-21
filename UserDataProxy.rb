require "net/https"
require "uri"
require 'json'
require_relative 'APIProxy'

class UserDataProxy < APIProxy

	def initialize(url)
		@url = url
	end

	def createObject 
		title = @object['title'].capitalize
		first = @object['first'].capitalize
		last = @object['last'].capitalize
		@name = "#{title} #{first} #{last}"
	end

	def makeRequest
		uri = URI.parse(@url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		body = JSON.parse(response.body.to_s)

		results = body['results']
		result = results[0]
		@object = result['name']
	end

	def getInfo
		begin
			makeRequest
			createObject
		rescue => e
			@name = "Mr Bob Smith"
		end
		@name
	end

end




#Code on how to add "results=<player_number>" to a url	
	
#		uri = URI(@url)
#		ar = URI.decode_www_form(uri.query) << ["results","#{player_number}"]
#		uri.query = URI.encode_www_form(ar)
#		@object = URI.parse(@url).read
