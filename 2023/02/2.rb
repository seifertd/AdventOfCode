SAVE_ARGV = ARGV[0..-1]

Game = Struct.new(:num, :blue, :red, :green) do
  def possible?
    self.blue <= 14 && self.green <= 13 && self.red <= 12
  end

  def power
    self.blue * self.red * self.green
  end
end

def parse_games
  ARGV.replace(SAVE_ARGV)
  games = []
  ARGF.each_line do |line|
    line.chomp!
    game_num, sets = line.split(": ")
    game_num = game_num.split(" ").last.to_i
    game = Game.new(game_num, 0, 0, 0)
    sets.split("; ").each do |set|
      set.split(", ").each do |selection|
        num, color = selection.split(" ")
        num = num.to_i
        color = color.to_sym
        game[color] = [game[color] || 0, num].max
      end
    end
    games << game
  end
  games
end

def part1
  result = 0
  parse_games.each do |g|
    if g.possible?
      result += g.num
    end
  end
  result
end

def part2
  parse_games.inject(0) { |sum, g| sum += g.power }
end

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
