require 'set'

Card = Struct.new(:card_no, :winners, :have, :copies) do 
  def initialize(card_no, winners, have)
    super
    self.copies = 1
  end
end

def parse_input
  cards = []
  ARGF.each_line do |line|
    line.chomp!
    card_header, values = line.split(": ")
    _, card_no = card_header.split(" ")
    card_no = card_no.to_i
    winners, have = values.split(" | ").map{|s| Set.new s.split(" ").map(&:to_i)}
    #puts "CARD #{card_no}: Winners: #{winners.inspect} Have: #{have.inspect} card class: #{Card.inspect}"
    cards << Card.new(card_no, winners, have)
  end
  cards
end

def part1(cards)
  cards.map do |card|
    num_winners = card.have.intersection(card.winners).size
    if num_winners > 0
      2 ** (num_winners - 1)
    else
      0
    end
  end.sum
end

def part2(cards)
  sum = 0
  cards.each.with_index do |card, cidx|
    num_winners = card.have.intersection(card.winners).size
    num_winners.times do |offset|
      cards[cidx + offset + 1].copies += card.copies
    end
    sum += card.copies
  end
  sum
end

cards = parse_input
puts "Part1: #{part1(cards)}"
puts "Part2: #{part2(cards)}"
