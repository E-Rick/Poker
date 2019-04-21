Proxy
---
Wrapper that adds additional functionality
Imposter class (counterfeit object) is called a Proxy by the GoF
	- has a reference to the real object, the Subject, hidden inside. 
	- whenever the client code calls a method on the proxy, the proxy simply forwards the request to the real object.

Weaknesses of Proxy
- Duplication of interface, could deal with that with method_missing
- Little bit of a performance hit, more classes (objects)
- Potential for data loss, especially with remote proxy.(knowing whether or not data was sent to server)

Protection Proxy
	- adds security
	- want separation of concerns, so you make a separate class. 
	- minimize change any important information will inadvertently leak out through our protective shield.
Remote Proxy
	- manages network connection.
	- provides a separation of concerns, proxy focuses on shitting bytes across the network.
 
Virtual Proxy
	- controls resources, wont create expensive objects unless absolutely necessary. (delays instantiation)
	- provides a separation of concerns, proxy deals with the issue of when to create the BankAccount instance.

Method_missing
	- can catch arbitrarily any method
	- painless method of delegation
Weaknesses
	- adds a performance hit
	- can obscure code


class A			class AProxy				class B (class that is using the class that needs to be proxied) (project3 case: the one running the numbers)
def foo		<-----	def foo			<--------
			#imp
end			end
expensive		delays instantiation

#If ruby can't find the method 
def method_missing(symbol, args)
	@obj.send(symbol, args)
end

***
obj.send(:method_name, parameters)

#To turn into a protection proxy simply add a check at the start of each method.
#Provides a nice separation of concerns, the proxy worries about who is or not allot to do what and the only thing the real bank account object need be conerned with is well, the bank account
class AccountProtectionproxy
	require 'etc'

	def initalize(real_account, owner_name)
		@subject = real_account
		@owner_name = owner_name
	end

#	def deposit(amount)
#		check_access
#		return @subject.deposit(amount)
#	end
#	def withdraw(amount)
#		check_access
#		return @subject.withdraw(amount)
#	end
#	def balance
#		check_access
#		return @subject.balance
#	end


	def method_missing(name, *args)
		check_access
		puts("Delegating #{name} message to subject")
		@subject.send(name, args)
	end

	def check_access
		if Etc.getlogin != @owner_name
			raise "Illegal access: #{Etc.getlogin} cannot access account."
		end
	end
end


Remote procedure call (RPC)

url = "http://...."

VIRTUAL PROXY
------------
class VirtualAccountProxy
	def initialize(&creation_block)
		@creation_block = creation_block
	end
	
	def deposit(amount)
		s = subject
		return s.deposit(amount)
	end

	def withdraw(amount)
		s = subject
		return s.withdraw(amount)
	end

	def balance
		s = subject
		return s.balance
	end
	
	#Heart of the virtual proxy method
	#Checks whether the BankAccount object has already been created and if not, creates one. 
	#Uses a big OR expression, if @subject is not nil, the evaluates to that non-nil value.
	def subject 
#		@subject || (@subject =  @creation_block.call)
		@subject = @creation_block.call unless @subject
		@subject
	end
end

account = VirtualAccountProxy.new(BankAccount.new(10))



Think about the forgotton object methods as you build your proxies. such as to_s




ISMAIL NOTES
------------

require 'json'
class APIProxy
	def createObject
		@ph = PokerHand.new
		@ph.odds = @object['odds']	
	end
	def makeRequest
		# => I DUNNO WHAT THIS IS USED FOR----->>>>
		open("http://stevenamoore.me/projects/holdemapi?cards=KsQs&board=As")
		JSON 
		#--------------------
		result = open(@url)
		@object = JSON.parse(result.to_s)
	end
end

class HoldEmAPIProxy < APIProxy
	def initialize(url)
		@url = url
	end
	def createObject()
		@ph = PokerHand.new
		@ph.odds = @object['odds']
	end
	def makeURL(cards, players, board)
		#implement!!
	end
	def getOdds(cards, players, board)
		self.makeURL(cards, players, board)
		self.makeRequest
		self.createObject
		return @ph.odds
	end
end

proxy = HoldEmAPIProxy.new

proxy.getOdds(cards, bum_players, board)
