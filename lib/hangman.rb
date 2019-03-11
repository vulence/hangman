require 'yaml'

class Hangman
	def initialize
		system("cls")
		puts <<~HERE
				Hello and welcome to the game called Hangman!
				
				The computer will randomly choose a word from a dictionary, length between 5-12 letters.
				In each move, you will insert a letter that you think the word contains.
				
				If you pick more than 6 letters that do not exist in the word, you will lose.
				If you guess the word correctly, you are the winner!
				
				Good luck!
				
			HERE
			
		@fails = 0
		@right_choices = ""
		@wrong_choices = ""
		
		puts "Do you want to load a saved game? (yes/no)"
		choice = gets.chomp.downcase
		
		while (choice != "yes" && choice != "no")
			print "yes/no: "
			choice = gets.chomp.downcase
		end
		
		if (choice == "yes")
			load
		end
		
		random_word
		play
	end
	
	def play
		system("cls")
		display
		
		while (@fails != 6)
			puts "Enter SAVE if you want to save the game.\n\n"
			print "Choose a letter: "
			@guess = gets.chomp.downcase
			
			if (@guess == "save")
				save
				display
				next
			end
			
			while (@guess.length != 1 || !@guess.match(/^[[:alpha:]]+$/) || @right_choices.include?(@guess) || @wrong_choices.include?(@guess) || @guess == "")
				if ((@right_choices.include?(@guess) || @wrong_choices.include?(@guess)) && @guess != "")
					puts "\n\nYou already guessed that letter.\n\n"
					display
				else
					puts "Invalid input\n\n"
					display
				end
				
				print "Choose a letter: "
				@guess = gets.chomp.downcase
			end
			
			if (!check_letters)
				puts "\nThat letter doesn't appear in the word"
				@wrong_choices += @guess
				display
				next
			end
			
			@right_choices += @guess
			replace_letters
			display
			
			win?
		end
		
		lose
	end
	
	def random_word
		dictionary = File.readlines("../5desk.txt")
		x = rand(0..61000)

		while(dictionary[x].length < 5 || dictionary[x].length > 12)
			x = rand(0..61000)
		end
	
		@word = dictionary[x].chomp.downcase.scan(/./).join(" ")
		@marked_word = @word.gsub(/[a-z]/, "_")
	end

	def check_letters
		if (!@word.include?(@guess))
			@fails += 1
			return false
		end
		
		return true
	end
	
	def replace_letters
		@marked_word = @word.gsub(/[^#{@right_choices}\s*]/, "_")
	end
	
	def win?
		if (@word == @marked_word)
			puts "Congrats, you won!"
			puts "The word was: #{@word.split.join.upcase}\n\n"
			new_game
		end
	end
	
	def lose
		puts "You ran out of guesses!"
		puts "The word was: #{@word.split.join.upcase}\n\n"
		new_game
	end
	
	def new_game
		puts "Do you want to start a new game? (yes/no)"
		newgame = gets.chomp.downcase
			
		while (newgame != "yes" && newgame != "no")
			print "Please enter a valid choice: "
			newgame = gets.chomp.downcase
		end
		
		if (newgame == "no")
			puts "Thank you for playing!"
			sleep(3)
			exit(0)
		else
			Hangman.new
		end
	end
	
	def display
		puts "\n\nWord: #{@marked_word}"
		puts "Right guesses: #{@right_choices.scan(/./).join(", ")}"
		puts "Wrong guesses: #{@wrong_choices.scan(/./).join(", ")}\n\n"
	end
	
	def save
		print "Please enter the name of the file you want to save the game to: "
		filename = gets.chomp.downcase
		
		File.open("../#{filename}.yaml", "w").write(YAML.dump(self))
		
		puts "File saved successfully!"
		sleep(1)
	end
	
	def load
		print "Please enter the name of the file you want to load the game from: "
		filename = gets.chomp.downcase
		
		game = YAML.load(File.open("../#{filename}.yaml"))
		game.play
	end
end

Hangman.new