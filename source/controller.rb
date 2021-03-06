require_relative 'model'

class Controller
  def initialize
    filename = validate_file(ARGV[0])
    deckname = filename.split(".").first

    @cards = Model.get_cards(filename)

    puts
    puts "Welcome to Ruby Flash Cards!"
    puts "Deck: #{deckname}"
    puts "To play, just enter the correct term for each definition. Type '.help' for other options."
    puts
    next_card
  end

  def validate_file(filename)
    if filename.nil?
      puts
      puts "Need to select file."
      print "> "
      validate_file($stdin.gets.chomp)
    elsif File.exist?(filename)
      filename
    else
      puts
      puts "Invalid file."
      print "> "
      validate_file($stdin.gets.chomp)
    end
  end

  def next_card
    @active_card = @cards.sample

    show_definition

    get_user_input
  end

  def print_line
    puts "-" * 50
  end

  def show_definition
    puts "DEFINITION"
    print_line
    puts @active_card.definition
    puts
  end

  def show_answer
    print_line
    puts "| ANSWER: #{@active_card.answer}".ljust(49, " ") + "|"
    print_line
    puts
  end

  def get_user_input
    puts "Guess (type '.help' for other options): "
    print "> "
    input = $stdin.gets.chomp

    if input == ".quit"
      puts
      puts "Thanks for playing!"
      exit
    elsif input == ".skip"
      puts
      show_answer
      next_card
    elsif input == ".help"
      puts
      puts "type '.quit' to exit,   type '.skip' to skip card"
      puts
      user_continue
      show_definition
      get_user_input
    else
      puts
      evaluate_guess(input)
    end
  end

  def user_continue
    print "[Hit <enter> to continue]"
    $stdin.gets.chomp
    puts
  end

  def evaluate_guess(guess)
    if guess == @active_card.answer
      puts "Correct!"
      puts
      next_card
    else
      @active_card.attempts += 1
      puts "Incorrect! Try again."
      puts
      show_definition
      get_user_input
    end
  end
end

Controller.new
