require '../../common/point.rb'
class Point
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x - 1, self.y-1),
      Point.new(self.x - 1, self.y+1),
      Point.new(self.x + 1, self.y),
      Point.new(self.x + 1, self.y-1),
      Point.new(self.x + 1, self.y+1),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols}
  end
end
class Solution
  def accessible?(p)
    p.neighbors(@rows,@cols).count do |p|
      @grid[p.y][p.x] == '@'
    end < 4
  end
  def parse
    @grid = []
    input do |line|
      @grid << line.split(//)
      @cols ||= @grid.last.size
    end
    @rows = @grid.size
  end
  def accessible_rolls
    points = []
    0.upto(@rows-1) do |row|
      0.upto(@cols-1) do |col|
        if @grid[row][col] == '@' && accessible?(Point.new(col,row))
          points << Point.new(col,row)
        end
      end
    end
    points
  end
  def part1
    parse
    count = 0
    accessible_rolls.count
  end
  def draw_grid
    printf("\033[H")
    @grid.each do |row|
      puts row.join
    end
  end
  def part2
    parse
    total_removed = 0
    printf("\033[2J") if ENV['ANIMATE']
    while true
      draw_grid if ENV['ANIMATE']
      puts "Total removed: #{total_removed}       " if ENV['ANIMATE']
      ar = accessible_rolls
      break if ar.count == 0
      total_removed += ar.count
      ar.each do |p|
        @grid[p.y][p.x] = '.'
      end
      sleep 0.3 if ENV['ANIMATE']
    end
    total_removed
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
    puts "  Provide ANIMATE=true environment variable to show animation for part2"
  end
end
