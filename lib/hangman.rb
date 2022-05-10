# frozen_string_literal: true

class Game
  attr_reader :guess, :game_over

  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'
  SAVE_PATH = 'save_game'

  def initialize
    @dictionary = File.open(DICTIONARY_PATH) { |f| f.readlines }
    @secret_word = @dictionary.select { |word| word.length > 4 && word.length < 13 }.sample.upcase.chomp
    @turn_counter = 0
    @guess = ''
    @hits = []
    @game_over = 0
  end

  def turn
    @turn_counter += 1
    get_guess
    matches = check
    draw_tracker
    if @hits.length == @secret_word.length
      puts 'You won!'
      @game_over = 1
    end
    save_prompt
  end

  def check
    matches = indices_of_matches(@secret_word, guess)
    if matches.to_a.length > 0
      track_hits(matches)
      matches
    else
      nil
    end
  end

  def draw_tracker
    print ".-"*30+".\n"
    print "Turn #{@turn_counter}\n\n"
    print "You guessed: #{@guess}\n"
    @secret_word.length.times do |i|
      if @hits.include?(i)
        print @secret_word[i]
      else
        print '_'
      end
    end
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
  game = Marshal.load(File.binread(Game::SAVE_PATH))
  game.draw_tracker
  game
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
game.turn until game.game_over == 1

