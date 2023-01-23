require_relative "./advent_of_code"

class Day18 < AdventOfCode
  class Universe
    BLOCK = 1
    INTERNAL = 2
    EXTERNAL = 4
    UNKNOWN = 8
    attr_reader :data, :min, :max
    def initialize(debug = false)
      @debug = debug
      @max = AdventOfCode::Point.new(-100,-100,-100)
      @min = AdventOfCode::Point.new(0,0,0)
      @data = []
      @points = []
    end
    def num_points
      @points.size
    end
    def length
      @max.x - @min.x + 1
    end
    def width
      @max.y - @min.y + 1
    end
    def height
      @max.z - @min.z + 1
    end
    def volume
      length * width * height
    end
    def edge?(x,y,z)
      x == 0 || x >= length - 1
        y == 0 || y >= width - 1
        z == 0 || z >= height - 1
    end
    # Return all points that are in interior air pockets
    def find_pockets
      pockets = []
      (@min.z..@max.z).each do |z|
        (@min.y..@max.y).each do |y|
          (@min.x..@max.x).each do |x|
            if pocket = inside_pocket_of(x,y,z)
              pockets << pocket
            end
          end
        end
      end
      pockets
    end
    def neighbors_of(x0,y0,z0)
      points = []
      xr = ([x0-1,0].max..[x0+1,length-1].min)
      yr = ([y0-1,0].max..[y0+1,width-1].min)
      zr = ([z0-1,0].max..[z0+1,height-1].min)
      zr.each {|z| points << [x0,y0,z] if z != z0 }
      yr.each {|y| points << [x0,y,z0] if y != y0 }
      xr.each {|x| points << [x,y0,z0] if x != x0 }
      points
    end
    def inside_pocket_of(x0,y0,z0)
      # Use 3D flood fill to find consecutive (non diagonal) points
      # that are empty and classify them as INTERNAL (inside pocket
      # of empty space) or EXTERNAL (pocket of empty space that
      # touches the edge). Returns the pocket as an array of
      # Points if it is INTERNAL
      #puts "CHECKING IF #{x0},#{y0},#{z0} is a pocket"
      if @data[z0][y0][x0] > 0
        return nil
      end
      state = edge?(x0,y0,z0) ? EXTERNAL : UNKNOWN
      @data[z0][y0][x0] |= state
      pocket = [AdventOfCode::Point.new(x0,y0,z0)]
      stack = []
      add_neighbors = lambda do |x0,y0,z0|
        neighbors_of(x0,y0,z0).each do |x,y,z|
          next if @data[z][y][x] > 0
          stack << [x,y,z]
        end
      end
      add_neighbors.call(x0,y0,z0)
      while !stack.empty?
        x,y,z = stack.shift
        if @data[z][y][x] == 0
          # if we reach the edge, this is an EXTERNAL pocket
          state = EXTERNAL if edge?(x,y,z)
          @data[z][y][x] = UNKNOWN 
          pocket << AdventOfCode::Point.new(x,y,z)
          add_neighbors.call(x,y,z)
        end
      end
      # We never reached an edge, this is an INTERNAL pocket
      state = INTERNAL if state == UNKNOWN
      pocket.each { |p| @data[p.z][p.y][p.x] |= state; @data[p.z][p.y][p.x] ^= UNKNOWN }
      if state == INTERNAL
        pocket
      else
        nil
      end
    end
    def build_data
      @min.z.upto(@max.z) do |z|
        @data[z] = []
        @min.y.upto(@max.y) do |y|
          @data[z][y] = [0] * length
        end
      end
      @points.each do |p|
        raise "Point #{p} already has data: #{data[p.z][p.y][p.x]}" if @data[p.z][p.y][p.x] > 0
        @data[p.z][p.y][p.x] |= BLOCK
      end
    end
    def add_point(p)
      puts "ADDING #{p}" if @debug
      @points << p
      @max.x = [@max.x, p.x].max
      @max.y = [@max.y, p.y].max
      @max.z = [@max.z, p.z].max
    end
    def []=(p,d)
      raise "x=#{p.x} out of bounds: #{@min.x}<=>#{@max.x}" if !(@min.x..@max.x).include?(p.x)
      raise "y=#{p.y} out of bounds: #{@min.y}<=>#{@max.y}" if !(@min.y..@max.y).include?(p.y)
      raise "z=#{p.z} out of bounds: #{@min.z}<=>#{@max.z}" if !(@min.z..@max.z).include?(p.z)
      @data[p.z][p.y][p.x] = d
    end
    def is_block?(x,y,z)
      ( @data[z][y][x] & BLOCK ) > 0
    end
    def [](p)
      raise "x=#{p.x} out of bounds: #{@min.x}<=>#{@max.x}" if !(@min.x..@max.x).include?(p.x)
      raise "y=#{p.y} out of bounds: #{@min.y}<=>#{@max.y}" if !(@min.y..@max.y).include?(p.y)
      raise "z=#{p.z} out of bounds: #{@min.z}<=>#{@max.z}" if !(@min.z..@max.z).include?(p.z)
      @data[p.z][p.y][p.x]
    end
  end

=begin
  u = Universe.new(true)
  p = Point.new(2,2,2)
  u.add_point(p)
  puts "DATA#{p}: #{u[p]}"
  puts "DATA: #{u.data.inspect}"
  p = Point.new(1,2,2)
  u.add_point(p)
  puts "DATA#{p}: #{u[p]}"
  puts "DATA: #{u.data.inspect}"
  p = Point.new(3,2,2)
  u.add_point(p)
  puts "DATA#{p}: #{u[p]}"
  puts "DATA: #{u.data.inspect}"
  p = Point.new(2,1,2)
  u.add_point(p)
  puts "DATA#{p}: #{u[p]}"
  puts "DATA: #{u.data.inspect}"
  p = Point.new(2,3,2)
  u.add_point(p)
  puts "DATA#{p}: #{u[p]}"
  puts "DATA: #{u.data.inspect}"
  exit 42
=end

  attr_reader :points
  def initialize
    super
  end
  def read_part2
    @universe = Universe.new
    @points = []
    read_input do |line|
      p = Point.new(*line.split(',').map(&:to_i))
      @universe.add_point p
      @points << p
    end
    @universe.build_data
    puts "read universe of #{@universe.num_points} points"
    puts " x: #{@universe.min.x}<=>#{@universe.max.x} length: #{@universe.length}"
    puts " y: #{@universe.min.y}<=>#{@universe.max.y}  width: #{@universe.width}"
    puts " z: #{@universe.min.z}<=>#{@universe.max.z} height: #{@universe.height}"
    exp_sides = exposed_sides
    pockets = @universe.find_pockets
    puts " found #{pockets.size} internal air pockets"
    pockets.each do |pocket|
      pocket.each do |p|
        neighbors = @universe.neighbors_of(p.x,p.y,p.z)
        neighbors.each do |x,y,z|
          if @universe.is_block?(x,y,z)
            exp_sides -= 1
          end
        end
      end
    end
    puts "Part 2: Number of exposed sides: #{exp_sides}"
  end

  def read_part1
    @points = []
    @max = Point.new(-100,-100,-100)
    @min = Point.new(100,100,100)
    read_input do |line|
      @points << Point.new(*line.split(',').map(&:to_i))
      @max.x = [@max.x, @points.last.x].max
      @min.x = [@min.x, @points.last.x].min
      @max.y = [@max.y, @points.last.y].max
      @min.y = [@min.y, @points.last.y].min
      @max.z = [@max.z, @points.last.z].max
      @min.z = [@min.z, @points.last.z].min
    end
    puts "Read #{@points.size} points, max=#{@max}, min=#{@min}"
  end
  def run
    if @part == 1
      part1
    else
      part2
    end
  end
  def part2
    read_part2
  end
  def exposed_sides
    sides = 0
    @points.size.times do |i|
      p1 = @points[i]
      sides += 6
      if i > 0
        (i-1).downto(0) do |j|
          p2 = @points[j]
          if (p1.x == p2.x && p1.y == p2.y && (p1.z-p2.z).abs == 1) ||
             (p1.y == p2.y && p1.z == p2.z && (p1.x-p2.x).abs == 1) ||
             (p1.x == p2.x && p1.z == p2.z && (p1.y-p2.y).abs == 1)
            sides -= 2
          end
        end
      end
    end
    sides
  end
  def part1
    read_part1
    puts "Part 1: Number of exposed sides: #{exposed_sides}"
  end
end

if __FILE__ == $PROGRAM_NAME
  solution = Day18.new
  solution.run
end
