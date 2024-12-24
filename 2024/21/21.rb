require '../../common/point'

NUMBER_BUTTONS = {
  A: Point.new(2,3), "3": Point.new(2,2), "6": Point.new(2,1), "9": Point.new(2,0),
  "0": Point.new(1,3), "2": Point.new(1,2), "5": Point.new(1,1), "8": Point.new(1,0),
  "1": Point.new(0,2), "4": Point.new(0,1), "7": Point.new(0,0), G: Point.new(0,3)
}
MOVE_BUTTONS = {
  A: Point.new(2,0), "^": Point.new(1,0), ">": Point.new(2,1),
  v: Point.new(1,1), "<": Point.new(0,1), G: Point.new(0,0)
}
class Keypad
  def initialize(rows, cols, buttons)
    @rows = rows
    @cols = cols
    @buttons = buttons
    @moves = Hash.new{|h,k| h[k] = []}
    buttons.values.each do |b1|
      buttons.values.each do |b2|
        next if b2 == b1 || b1 == self.gap || b2 == self.gap
        @moves[[b1, b2]] = b1.taxi_paths(b2) do |np|
          [
            Point.new(np.x, np.y + 1),
            Point.new(np.x, np.y - 1),
            Point.new(np.x + 1, np.y),
            Point.new(np.x - 1, np.y)
          ].reject {|p| p == self.gap || p.x < 0 || p.y < 0 || p.x > cols - 1 || p.y > rows - 1 }
        end
      end
    end
  end
  def gap
    @buttons[:G]
  end
  def press(b1, b2)
    if b1 == b2
      return [[:A]]
    end
    b1 = @buttons[b1]
    b2 = @buttons[b2]
    @moves[[b1, b2]].map do |move|
      move << :A unless move.last == :A
      move
    end
  end
end
class Solution
  def robot_len(movepad, moves, depth, cache)
    return moves.size if depth <= 0
    key = [moves, depth]
    return cache[key] if cache.key?(key)
    cmd_len = 0
    b1 = :A
    moves.each do |b2|
      min_len = nil
      movepad.press(b1, b2).each do |seq|
        #debug { "MOVEPAD MOVES #{b1} - #{b2}: #{seq.inspect}\n"}
        next_len = robot_len(movepad, seq, depth-1, cache)
        min_len = min_len.nil? ? next_len : [min_len, next_len].min
      end
      cmd_len += (min_len || 0)
      b1 = b2
    end
    cache[key] = cmd_len
    cmd_len
  end
  def complexity(numpad, movepad, depth, cache, b1, b2)
    min_len = nil
    numpad.press(b1, b2).each do |moves|
      robot_len = robot_len(movepad, moves, depth, cache)
      min_len = min_len.nil? || robot_len < min_len ? robot_len : min_len
    end
    min_len
  end
  def find_complexity(numbots, cache = {})
    numpad = Keypad.new(4,3,NUMBER_BUTTONS)
    movepad = Keypad.new(2,3,MOVE_BUTTONS)
    score = 0
    input do |line|
      b1 = :A
      comp = 0
      line.split(//).map(&:to_sym).each do |b2|
        comp += complexity(numpad, movepad, numbots, cache, b1, b2)
        b1 = b2
      end
      comp = comp * line.to_i
      debug { "CODE: #{line} COMPLEXITY: #{comp}\n"}
      score += comp
    end
    score
  end
  def part1
    find_complexity(2)
  end
  def part2
    find_complexity(25)
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug
    print(yield) if ENV['DEBUG']
  end
end

if __FILE__ == $0
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    solution = Solution.new
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    solution = Solution.new
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
