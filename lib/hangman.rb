# frozen_string_literal: true

class Game
  attr_reader :guess

  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'
  SAVE_PATH = 'save_game'

  def initialize
    @dictionary = File.open(DICTIONARY_PATH) { |f| f.readlines }
    @secret_word = @dictionary.select { |word| word.length > 4 && word.length < 13 }.sample
    @guess = ''
  end

  def turn
    get_guess
    check
  end

  def check

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
  Marshal.load(File.binread(SAVE_PATH))
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

