class Card
  attr_reader :definition, :answer
  attr_accessor :attempts

  def initialize(args)
    @definition = args[:definition]
    @answer = args[:answer]
    @attempts = 0
  end
end

module Model
  def self.save_cards(file_path)
    # returns an array of values from file [definition1, answer1, definition, answer2]
    File.readlines(file_path).each do |line|
      line.gsub!("\n",'') #remove line breaks
    end.select{|line| line != ""} # select only non-empty lines
  end

  def self.get_cards(file_path)
    card_objects = []
    card_array = Model.save_cards(file_path)
    card_array.each_slice(2).to_a.each{|pair| card_objects << Card.new(Hash[[:definition,:answer].zip(pair)])}
    card_objects
  end
end
