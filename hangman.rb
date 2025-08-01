class Hangman
  def game_start
    select_game_mode

    if @game_mode == 'n'
      initialize_game
    elsif @game_mode == 'c'
      continue_game
    end

    play_game
  end

  def select_game_mode
    puts 'Playing hangman.'
    puts 'n: New game'
    puts 'c: Continue'

    valid_inputs = %w(n c)

    loop do
      input = gets.chomp.downcase

      if valid_inputs.include?(input)
        @game_mode = input
        break
      else
        puts 'Invalid input. Valid inputs are'
        puts 'n: New game'
        puts 'c: Continue'
      end
    end
  end

  # Assign a random word from the dictionary that has a word length of 5-12 as an answer 
  # and set @player_answer to a bunch of underscores of the same length of the answer
  def initialize_game
    dictionary = File.readlines('google-10000-english-no-swears.txt', chomp: true)
    @allowed_incorrect_guesses = 7

    loop do
      random_word = dictionary.sample

      if random_word.length.between?(5, 12)
        @answer = random_word

        blank_answer = []

        @answer.length.times do
          blank_answer << '_'
        end

        @player_answer = blank_answer.join
        break
      end
    end
  end

  # Loads the game state from a save file consisting of three lines of string
  def continue_game
    File.open('hangman_save_file.txt', 'r') do |save_file|
      @answer = save_file.gets.chomp
      @player_answer = save_file.gets.chomp
      @allowed_incorrect_guesses = save_file.gets.chomp.to_i
    end

    puts 'Save file loaded.'
  end

  def play_game
    puts 'Enter a single character to guess.'
    puts "You can enter 'save' to save your progression."

    loop do
      puts "#{@allowed_incorrect_guesses} incorrect guesses allowed."
      puts "Player answer: #{@player_answer}"

      print 'Enter a character: '
      @input_guess = gets.chomp.downcase

      break if evaluate_input
      break if check_game_over
    end
  end

  def evaluate_input
    if @input_guess == 'save'
      save_game
      return true
    end

    if @input_guess.length == 1 && @input_guess.ord.between?(97, 122)
      correct_answer = false

      @answer.chars.each_with_index do |chr, i|
        if @input_guess == chr
          @player_answer[i] = chr
          correct_answer = true
        end
      end

      @allowed_incorrect_guesses -= 1 unless correct_answer == true
    else
      puts 'Invalid input. Try again'
    end

    false
  end
  
  def check_game_over
    if @allowed_incorrect_guesses <= 0
      puts "You lose. the correct answer was '#{@answer}'"
      return true
    end

    if @player_answer == @answer
      puts "You win! the correct answer was '#{@answer}'"
      return true
    end

    false
  end

  # Saves game state as a string in three lines
  def save_game
    File.open('hangman_save_file.txt', 'w') do |save_file|
      save_file.puts @answer
      save_file.puts @player_answer
      save_file.puts @allowed_incorrect_guesses
    end

    puts 'Game saved.'
  end
end

new_game = Hangman.new
new_game.game_start
