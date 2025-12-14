require '../../common/point'

class Grid
  attr_accessor :width, :height, :shapes
  attr_reader :grid
  def initialize(w, h)
    @width = w
    @height = h
    @grid = Array.new(@height) { 0 }
    @placed = []
  end
  def area
    @width * @height
  end
  def free_area
    area - @places.size * 7
  end
  def unpacked_capacity
    (self.width / 3) * (self.height / 3)
  end
  def reset
    @grid = Array.new(@height) { 0 }
  end
  def to_s
    "Grid: #{@width}x#{@height} #{@grid.inspect} shapes: #{@shapes.inspect}"
  end
  def inspect
    to_s
  end
end
class Shape
  attr_accessor :grid, :area
  def initialize
    @grid = []
  end
  def set_area
    @area = @grid.inject(0) { |s, n| s += n.to_s(2).count('1') }
  end
  def to_s
    "Shape: #{@grid.inspect} A:#{@area}"
  end
  def inspect
    to_s
  end
end
class Solution
  def parse
    @shapes = []
    @grids = []
    shape = nil
    input do |line|
      if line =~ /^\d+:/
        shape = Shape.new
        @shapes << shape
      elsif line =~ /^(\d+)x(\d+):/
        grid = Grid.new($1.to_i, $2.to_i)
        grid.shapes = line.split(": ")[-1].split(" ").map(&:to_i)
        @grids << grid
      elsif line =~ /^[#\.]+$/
        shape.grid << line.gsub('#', '1').gsub('.', '0').to_i(2)
        if shape.grid.size == 3
          shape.set_area
        end
      end
    end
  end
  COMBOS = [
    [[3,5,3], [7,3], 0],
    [[0,2,0], [7,3], 0],
    [[0,1,3], [7,3], 0],
    [[4,4,0,0,2], [6,6], 1],
    [[4,4,0,0,1], [6,6], 1],
    [[3,3,1,0,0,3,1,1], [10,6], 4],
    [[3,3,1,0,0,3,1,4], [10,6], 4],
    [[3,3,1,0,0,3,1,5], [10,6], 4],
    [[3,3,1,0,0,3,5,1], [10,6], 4],
    [[3,3,1,0,0,3,5,4], [10,6], 4],
    [[3,3,1,0,0,3,5,5], [10,6], 4],
    [[3,3,1,0,0,3,0,1], [10,6], 4],
    [[3,3,1,0,0,3,0,4], [10,6], 4],
    [[3,3,1,0,0,3,0,5], [10,6], 4],
    [[1,3], [5,3], 1],
    [[0,2], [5,3], 1],
    [[4,3], [5,3], 1],
    [[4,4], [4,4], 2],
    [[0,3,1], [8,3], 3],
    [[0,3,5], [8,3], 3],
    [[5,5], [4,5], 6],
    [[2,2], [4,3], 6]
  ]
  def shapes_fit(g)
    # Make a copy of the grid
    g = Marshal.load(Marshal.dump(g))
    gs_total = g.shapes.inject(&:+)
    gs_area = gs_total * 7
    holes_avail = g.area - gs_area
    return false if g.area < gs_area
    # without packing, how many shapes fit
    if g.unpacked_capacity >= gs_total
      return true
    end
    debug { "Grid Area: #{g.area} Shape Area: #{gs_area} Holes: #{holes_avail}\n" }
    true
  end
  def part1
    parse
    debug { "SHAPES: #{@shapes.count}\n" }
    debug { "GRIDS: #{@grids.count}\n" }
    @grids.count { |g| shapes_fit(g) }
  end
  def part2
    raise "part2 solution not implemented"
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
