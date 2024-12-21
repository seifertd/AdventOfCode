require_relative '../../common/point'
require_relative '../../common/astar'
# To run for sample input:
# ROWS=7 COLS=7 DROPS=12 DEBUG=true ruby 18.rb [part1|part2] sample.txt

class Point
  def neighbors(grid, rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols || grid[y][x] != '.'}
  end
end
class Solution
  def draw_grid(grid)
    puts grid.map{|row| row.join}.join("\n")
  end
  def read_bytes
    bytes = []
    input do |line, idx|
      x, y = line.split(",").map(&:to_i)
      bytes << Point.new(x, y)
    end
    bytes
  end
  def initial_drops
    rows = (ENV['ROWS'] || 71).to_i
    cols = (ENV['COLS'] || 71).to_i
    grid = []
    rows.times do |y|
      grid << ['.'] * cols
    end
    def grid.g_score(from, to)
      1
    end
    def grid.h_score(from, to, goal)
      from.taxi_dist(to)
    end
    def grid.neighbors(to, path)
      to.neighbors(self, self.size, self[0].size)
    end
    bytes = read_bytes
 
    num_drops = (ENV['DROPS'] || 1024).to_i
    num_drops.times do |idx|
      grid[bytes[idx].y][bytes[idx].x] = '#'
      if idx == num_drops - 1
        debug { "LAST DROP: #{bytes[idx]}, idx = #{idx}\n" }
      end
    end
    return [grid, rows, cols, bytes, num_drops]
  end
  def part1
    grid, rows, cols, bytes = initial_drops
    draw_grid(grid) if ENV["DEBUG"]
    best_path = AStar.optimal_path(grid, Point.new(0,0), Point.new(cols-1,rows-1))
    best_path.each {|p| grid[p.y][p.x] = 'O'}
    draw_grid(grid) if ENV["DEBUG"]
    best_path.uniq.size - 1
  end
  def part2
    grid, rows, cols, bytes, num_drops = initial_drops
    curr_best_path = AStar.optimal_path(grid, Point.new(0,0), Point.new(cols-1,rows-1))
    debug {"NEXT DROP: #{bytes[num_drops]}, idx = #{num_drops}\n"}
    bad_byte = nil
    bytes[num_drops..-1].each do |byte|
      grid[byte.y][byte.x] = '#'
      if curr_best_path.include?(byte)
        curr_best_path = AStar.optimal_path(grid, Point.new(0,0), Point.new(cols-1,rows-1))
        debug {"DROPPED BYTE #{byte} PATH SIZE: #{curr_best_path.size}\n"}
        if curr_best_path.size == 0
          debug {"No path with byte #{byte}\n"}
          bad_byte = byte
          break
        end
      else
        debug {"DROPPED BYTE #{byte}, BUT NOT ON PATH\n"}
      end
    end
    bad_byte.to_s
  end
  def input
    ARGF.each_line.with_index do |line, idx|
      line.chomp!
      yield(line, idx)
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
