# Poker
Poker game built with Ruby


Project Structure

APIProxy.rb
- An Abstract Class that should work for any API call with a JSON response

PokerOddsProxy.rb
- Concrete class that derives from APIProxy and makes a call the the supplied holdemdapi

Database.rb
- Encapsulates the Database functionality, such reading in the JSON file, writing the JSON file. Updating the database objects.

Player.rb
- Contains player’s name, cards, and bankroll

Card.rb
Contains the card’s suit and value

Deck.rb
- An aggregate class that contains 52 cards at the start of each game.
- The cards should be shuffled before each game.
Should use the Enumerable Module to iterate through the deck

Table.rb
- An aggregate class that contains up to 8 players.
- Should also keep track of who is dealing, the current pot, who is in the game, who has folded, etc.
- Should use the Enumerable Module to iterate through the Players

main.rb
- Driver code
