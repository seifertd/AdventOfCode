CARDS = {'2' => 1 ,'3' => 2,'4' => 3,'5' => 4,'6' => 5,'7' => 6,'8' => 7,
         '9' => 8,'T' => 9,'J' => 10,'Q' => 11,'K' => 12,'A' => 13}
CARDS_P2 = {'J' => 1, '2' => 2 ,'3' => 3,'4' => 4,'5' => 5,'6' => 6,'7' => 7,
            '8' => 8, '9' => 9,'T' => 10,'Q' => 11,'K' => 12,'A' => 13}
Hand = Struct.new(:cards, :bid) do
  def rank(jokers = false)
    hand = self.cards.sort_by{|c| CARDS[c]}
    if five_of_kind(hand)
      1
    elsif four_of_kind(hand)
      if jokers && hand.count('J') > 0
        # this is now 5 of a kind
        1
      else
        2
      end
    elsif full_house(hand)
      if jokers && hand.count('J') > 0
        # this is now 5 of a kind
        1
      else
        3
      end
    elsif three_of_a_kind(hand)
      if jokers
        num_jokers = hand.count('J')
        raise "IMPOSSIBLE, 2 pair hand can only contain 1, 2 or 3 jokers: #{hand.inspect}" if num_jokers > 3
        if num_jokers == 1
          # now four of a kind
          2
        elsif num_jokers == 2
          # now five of a kind
          1
        elsif num_jokers == 3
          # now four of a kind (3 J + 1 other card)
          2
        else
          4
        end
      else
        4
      end
    elsif two_pair(hand)
      if jokers
        num_jokers = hand.count('J')
        raise "IMPOSSIBLE, 2 pair hand can only contain 1 or 2 jokers: #{hand.inspect}" if num_jokers > 2
        if num_jokers == 1
          # now a full house
          3
        elsif num_jokers == 2
          # now four of a kind
          2
        else
          5
        end
      else
        5
      end
    elsif one_pair(hand)
      if jokers
        num_jokers = hand.count('J')
        raise "IMPOSSIBLE, 1 pair hand can only contain 1 or 2 jokers: #{hand.inspect}" if num_jokers > 2
        if num_jokers == 2
          # now 3 of a kind (2 jokers + 1 other card)
          4
        elsif num_jokers == 1
          # now 3 of a kind (the pair + a joker)
          4
        else
          6
        end
      else
        6
      end
    else
      # high card
      if jokers
        raise "IMPOSSIBLE, high card hand can only contain 1 joker" if hand.count('J') > 1
        if hand.count('J') == 1
          # now 1 pair
          6
        else
          7
        end
      else
        7
      end
    end
  end

  def five_of_kind(hand)
    hand[0] == hand[1] &&
      hand[1] == hand[2] && 
      hand[2] == hand[3] && 
      hand[3] == hand[4]
  end

  def four_of_kind(hand)
    hand[1] == hand[2] && hand[2] == hand[3] && (hand[0] == hand[1] || hand[3] == hand[4])
  end

  def full_house(hand)
    (hand[0] == hand[1] && (hand[2] == hand[3] && hand[3] == hand[4])) ||
    (hand[3] == hand[4] && (hand[0] == hand[1] && hand[1] == hand[2]))
  end

  def three_of_a_kind(hand)
    ans = (hand[0] == hand[1] && hand[1] == hand[2]) ||
    (hand[1] == hand[2] && hand[2] == hand[3]) ||
    (hand[2] == hand[3] && hand[3] == hand[4])
    ans
  end

  def two_pair(hand)
    (hand[0] == hand[1] && hand[2] == hand[3]) ||
    (hand[0] == hand[1] && hand[3] == hand[4]) ||
    (hand[1] == hand[2] && hand[3] == hand[4])
  end

  def one_pair(hand)
    ans = (hand[0] == hand[1]) ||
    (hand[1] == hand[2]) ||
    (hand[2] == hand[3]) ||
    (hand[3] == hand[4])
    ans
  end
end

def parse_hands
  ARGF.readlines.map do |line|
    line.chomp!
    cards, rank = line.split(" ")
    Hand.new cards.split(//), rank.to_i
  end
end

def part1(hands)
  ranked = hands.sort do |h1,h2|
    r1 = h1.rank
    r2 = h2.rank
    if r1 == r2
      i = 0
      while CARDS[h1.cards[i]] == CARDS[h2.cards[i]]
        i += 1
      end
      if i > 4
        0
      else
        CARDS[h1.cards[i]] - CARDS[h2.cards[i]]
      end
    else
      r2 - r1
    end
  end
  rank = 0
  ranked.inject(0) do |s, hand|
    rank += 1
    s += rank * hand.bid
  end
end
def part2(hands)
  ranked = hands.sort do |h1,h2|
    r1 = h1.rank(true)
    r2 = h2.rank(true)
    if r1 == r2
      i = 0
      while CARDS_P2[h1.cards[i]] == CARDS_P2[h2.cards[i]]
        i += 1
      end
      if i > 4
        0
      else
        CARDS_P2[h1.cards[i]] - CARDS_P2[h2.cards[i]]
      end
    else
      r2 - r1
    end
  end
  rank = 0
  ranked.inject(0) do |s, hand|
    rank += 1
    s += rank * hand.bid
  end
end

hands = parse_hands
puts "Part 1: #{part1(hands)}"
puts "Part 2: #{part2(hands)}"
