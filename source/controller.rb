require_relative 'model'

class Controller
  def initialize
    filename = validate_file(ARGV[0])
    deckname = filename.split(".").first

    @deck = Deck.new(filename)
    @active_card = @deck.active_card
    @deck.mode = "main"
    @review_i = 0

    puts "\e[H\e[2J"
    puts "*" * 75
    puts "*" + " " * 73 + "*"
    puts "*" + " " * 73 + "*"
    puts "*" + "WELCOME TO FLASHCARDS GORDON!".center(73, " ") + "*"
    puts "*" + " " * 73 + "*"
    puts "*" + " " * 73 + "*"
    puts "*" * 75
    puts
    puts "To play, just guess the term. Type '.help' for other options."
    puts
    user_continue
    next_card
  end

  def validate_file(filename)
    if filename == ".quit"
      exit
    elsif filename.nil?
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
    @active_card.hints = 0

    if @deck.mode == "main"
      @active_card = @deck.active_card
    elsif @deck.mode == "review"
      @active_card = @deck.review_card(@review_i)
    end

    show_definition
  end

  def print_line
    puts "-" * 75
  end

  def show_definition(hint = "")
    puts "\e[H\e[2J"
    print "DEFINITION || #{@deck.mode.upcase} MODE"
    print " (#{@deck.review_cards.length - @review_i} REVIEW CARDS REMAINING)" if @deck.mode == "review"
    puts
    print_line
    puts @active_card.definition
    puts
    puts hint
    get_user_input
  end

  def show_answer
    print_line
    puts "| ANSWER: #{@active_card.answer}".ljust(74, " ") + "|"
    print_line
    user_continue
  end

  def get_user_input
    puts "Guess (type '.help' for other options): "
    print "> "
    input = $stdin.gets.chomp

    if input == ".quit"
      quit_command
    elsif input == ".skip"
      skip_command
    elsif input == ".help"
      help_command
    elsif input == ".review" && @deck.mode == "main"
      review_command
    elsif input == ".main" && @deck.mode == "review"
      puts "WARNING: All remaining review cards will be lost. Continue? (Y/N)"
      print "> "
      answer = confirm_choice
      @deck.mode = "main" if answer.downcase == "y"
      next_card
    elsif input == ".hint"
      hint_command
    elsif input == ".add"
      add_command
    else
      puts
      evaluate_guess(input)
    end
  end

  def confirm_choice
    $stdin.gets.chomp
  end

  def quit_command
    @deck.save
    puts
    puts "Deck saved."
    puts
    puts "Thanks for playing!"
    exit
  end

  def skip_command
    puts
    show_answer
    @review_i += 1 if @deck.mode == "review"
    @deck.mode = "main" if @review_i > @deck.review_cards.length - 1

    next_card
  end

  def help_command
    puts
    if @deck.mode == "main"
      puts ".review    .hint    .skip    .add    .quit"
    elsif @deck.mode == "review"
      puts ".main    .hint    .skip    .add    .quit"
    end
    user_continue
    show_definition
  end

  def review_command
    @deck.get_review_cards

    if @deck.review_cards.empty?
      puts
      puts "No cards to review."
      user_continue
      show_definition
    else
      @deck.mode = "review"
      @review_i = 0
      next_card
    end
  end

  def hint_command
    if @active_card.hints == @active_card.answer.length
      puts
      show_answer
      next_card
    else
      show_definition("HINT: #{@active_card.hint}")
    end
  end

  def add_command
    puts
    puts "Input definition:"
    print "> "
    definition = $stdin.gets.chomp

    puts
    puts "Input answer:"
    print "> "
    answer = $stdin.gets.chomp

    @deck.add_card(definition, answer)

    show_definition
  end

  def user_continue
    puts
    print "[Hit <enter> to continue]"
    $stdin.gets.chomp
    puts
  end

  def evaluate_guess(guess)
    if guess == @active_card.answer
      puts "Correct!"
      puts
      @review_i += 1 if @deck.mode == "review"
      @deck.mode = "main" if @review_i > @deck.review_cards.length - 1
      next_card
    else
      @active_card.attempts += 1
      puts "Incorrect! Try again."
      puts
      show_definition
    end
  end
end

Controller.new
