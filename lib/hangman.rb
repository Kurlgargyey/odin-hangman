# frozen_string_literal: true

class Game
  attr_reader :guess, :game_over

  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'
  SAVE_PATH = 'save_game'

  def initialize
    @dictionary = File.open(DICTIONARY_PATH) { |f| f.readlines }
    @secret_word = @dictionary.select { |word| word.length > 4 && word.length < 13 }.sample.upcase.chomp
    @max_guesses = 10
    @turn_counter = 0
    @guess = ''
    @hits = []
    @misses = []
    @game_over = 0
  end

  def turn
    if @max_guesses == 0
      abort "You ran out of guesses..."
    end
    @turn_counter += 1
    get_guess
    matches = check_hits
    draw_state
    if @hits.length == @secret_word.length
      abort 'You won!'
    end
    save_prompt
  end

  def check_hits
    matches = indices_of_matches(@secret_word, guess)
    if matches.to_a.length > 0
      track_hits(matches)
      matches
    else
      @max_guesses -= 1
      @misses.push(guess)
      nil
    end
  end

  def draw_state
    print ".-"*30+".\n"
    print "Turn #{@turn_counter}\n\n"
    print "Mistakes left: #{@max_guesses}\n"
    print "You guessed: #{@guess}\n\n"
    @secret_word.length.times do |i|
      if @hits.include?(i)
        print @secret_word[i]+" "
      else
        print '_ '
      end
    end
    print "\n\nMisses: \n"
    @misses.each { |e| print e+' '}
    print "\n"+".-"*30+".\n"
  end

  def track_hits (array)
    array.each do |element|
      @hits.push element
    end
    @hits.uniq!
  end
  
  def get_guess
    puts "Please enter a guess!"
    self.guess = gets.chomp.upcase
    guess
  end

  def guess= (string)
    if validate(string)
      @guess = string
    else
      puts 'Make sure you enter a single alphabetic character.'
      get_guess
    end
  end

  def validate(string)
    string.length == 1 && string =~ /\A[[:alpha:]]+\z/
  end

  def save_prompt
    puts "Do you want to save and exit the game?"
    ans = yes_no_prompt
    if ans == 'Y'
      puts "Saving game..."
      save_game
      abort "Exiting game..."
    end
  end

  def save_game
    serialized_game = Marshal.dump(self)

    File.open(SAVE_PATH, 'wb') do |file|
      file.write(serialized_game)
    end
  end

  def indices_of_matches(str, target)
    sz = target.size
    (0..str.size - sz).select { |i| str[i, sz] == target }
  end
end

def load_game
  Marshal.load(File.binread(Game::SAVE_PATH))
end

def yes_no_prompt
  ans = gets.chomp.upcase until %w[Y N].include?(ans)
  ans
end

def continue_prompt
  if File.exist?(Game::SAVE_PATH)
    puts 'Would you like to load your previous game?'
    ans = yes_no_prompt  
    if ans == 'Y'
      puts 'Loading game...'
      load_game
    else
      puts 'Starting new game...'
      Game.new
    end
  else
    puts 'Starting new game...'
    Game.new
  end
end

game = continue_prompt
game.draw_state
game.turn while true

