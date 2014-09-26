class Card
  attr_reader :definition, :answer
  attr_accessor :attempts, :hints

  def initialize(args)
    @definition = args[:definition]
    @answer = args[:answer]
    @attempts = 0
    @hints = 0
  end

  def hint
    @hints += 1
    @answer[0...@hints]
  end
end

class Deck
  attr_accessor :cards, :review_cards, :mode

  def initialize(file_path)
    @file_path = file_path
    @cards = []
    @review_cards = []
    @mode = "main"

    card_array = File.readlines(file_path).each do |line|
      line.gsub!("\n",'') #remove line breaks
    end.select{|line| line != ""} # select only non-empty lines

    card_array.each_slice(2).to_a.each{|pair| @cards  << Card.new(Hash[[:definition,:answer].zip(pair)])}
  end

  def save
    File.open(@file_path, "w") do |file|
      @cards.each do |card|
        file.puts(card.definition)
        file.puts(card.answer)
        file.puts
      end
    end
  end

  def add_card(definition, answer)
    @cards << Card.new(:definition => definition, :answer => answer)
  end

  def active_card
    @cards.sample
  end

  def get_review_cards
    @review_cards = @cards.select { |card| card.attempts > 0 }
    @review_cards.each { |card| card.attempts = 0 }
  end

  def review_card(i)
    @review_cards[i]
  end
end
