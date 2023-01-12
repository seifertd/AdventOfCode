require 'ruby-progressbar'
require_relative './advent_of_code'

# Notes:
# Looking at the puzzle input, storing a big grid is not going to work
# as the coordinates are huge. Approach, build a sparse grid:
# row 0 y1: x1:b   x2:dz  x2:s  x3:dz  .....
# each row index will point at a array of y-coordinates
# each col index will point at a array of x-coordinates
# Need some functions to add objects to the smart grid, regen the 
# coordinate to value maps, etc
# To count the dead space, iterate over the rows and do subtractions of
# consecutive dz coordinates (number of cells in the deadzone)
#   * NOTE: Need to handle the case where a DZ does not pair up, so need
#           dz_begin and dz_end markers
#   * grid values will be bit map of object types
class Day15 < AdventOfCode
  BEACON = 1
  SENSOR = 2
  DZ_BEGIN = 4
  DZ_END = 8
  DZ = 16
  class SparseGrid
    attr_accessor :xmax, :xmin, :ymax, :ymin
    def initialize
      @grid = []
      @xs = []
      @ys = []
      @xmax = @ymax = -1_000_000
      @xmin = @ymin = 1_000_000
    end
    def draw_compact
      @grid.each.with_index do |row, yidx|
        printf "%10d: ", @ys[yidx]
        row.each do |val|
          if (val & SENSOR) > 0
            print 'S'
          elsif (val & BEACON) > 0
            print 'B'
          elsif (val & DZ) > 0
            print 'D'
          else
            print '.'
          end
        end
        puts
      end
    end
    def draw
      @grid.each.with_index do |row, ridx|
        if ridx > 0
          (@ys[ridx] - @ys[ridx - 1] - 1).times do |j|
            printf "%6d: %s\n", @ys[ridx-1] + j + 1, "." * (@xmax - @xmin + 1)
          end
        end
        printf "%6d: ", @ys[ridx]
        dead_stack = 0
        empty_char = '.'
        row.each.with_index do |val, cidx|
          if cidx > 0
            print empty_char * (@xs[cidx] - @xs[cidx-1] - 1)
          end
          if (val & DZ_BEGIN) > 0
            dead_stack += 1
            empty_char = '#'
          end
          if (val & BEACON) > 0
            print 'B'
          elsif (val & SENSOR) > 0
            print 'S'
          else
            print empty_char
          end
          if (val & DZ_END) > 0
            dead_stack -= 1
            empty_char = '.' if dead_stack <= 0
          end
        end
        puts
      end
    end

    def value_at(x,y)
      yidx = @ys.find_index(y)
      xidx = @xs.find_index(x)
      return 0 if yidx.nil? || xidx.nil?
      @grid[yidx][xidx]
    end
    def add_value(x, y, val)
      #puts "BEFORE ADD #{x},#{y} => #{val}"
      #puts self.inspect
      yidx = y_index(y)
      #puts "yidx = #{yidx}: #{self.inspect}"
      xidx = x_index(x)
      @grid[yidx][xidx] |= val
      #puts "xidx = #{xidx}: #{self.inspect}"
      @xmin = [@xmin, x].min
      @ymin = [@ymin, y].min
      @xmax = [@xmax, x].max
      @ymax = [@ymax, y].max
    end
    def rows
      @grid.size
    end
    def cols
      @grid.first.size
    end
    private
    def x_index(x)
      idx = @xs.find_index{|val| val >= x}
      if idx.nil?
        @xs << x
        @grid.each {|row| row << 0}
        @xs.size - 1
      elsif @xs[idx] == x
        idx
      else
        # insert
        @xs.insert(idx, x)
        @grid.each do |row|
          row.insert(idx, 0)
        end
        idx
      end
    end
    def y_index(y)
      idx = @ys.find_index{|val| val >= y}
      #puts " --> idx of #{y} in @ys = #{idx.inspect}"
      if idx.nil?
        @ys << y
        @grid << ([0] * (@grid.first || []).size)
        @ys.size - 1
      elsif @ys[idx] == y
        idx
      else
        # insert
        @ys.insert(idx, y)
        @grid.insert(idx, [0]*@grid.first.size)
        idx
      end
    end
  end
  def initialize
    super
    @sensors = []
    @grid = SparseGrid.new
  end
  def dead_zones_for(s, dist)
    ymin = s.y - dist
    ymax = s.y + dist
    width = 1
    step = 2
    ymin.upto(ymax) do |y|
      if width == 1
        @dead_zones[y] << (s.x..s.x)
      else
        @dead_zones[y] << ((s.x - width/2)..(s.x+width/2))
      end
      width += step
      step = -2 if width >= (dist*2 + 1)
    end 
  end
  def load_data
    read_input do |line|
      sdata, bdata = line.split(':')
      sensor = Point.new
      beacon = Point.new
      sdata.scan(/([xy])=(-?\d+)/) do |coord, val|
        sensor.send("#{coord}=".to_sym, val.to_i)
      end
      bdata.scan(/([xy])=(-?\d+)/) do |coord, val|
        beacon.send("#{coord}=".to_sym, val.to_i)
      end
      puts "Added sensor at #{sensor}, beacon at #{beacon}"
      @sensors << [sensor, beacon]
      @grid.add_value(sensor.x, sensor.y, SENSOR)
      @grid.add_value(beacon.x, beacon.y, BEACON)
    end
    # validate
    @sensors.each do |s, b|
      if (@grid.value_at(s.x, s.y) & SENSOR) == 0
        raise "Grid did not save SENSOR #{s} correctly"
      end
      if (@grid.value_at(b.x, b.y) & BEACON) == 0
        raise "Grid did not save BEACON #{s} correctly"
      end
    end
  end
  def add_dead_zones
    @dead_zones = Hash.new{|h,k| h[k] = []}
    @sensors.each do |s,b|
      puts "DEAD: #{s} => #{b} dist: #{s.taxi_dist(b)}"
      dead_zones_for(s, s.taxi_dist(b))
    end
    puts "MERGING #{@dead_zones.count} DEAD ZONES"
    @dead_zones.each do |y, ranges|
      new_ranges = []
      puts "SORTING RANGES FOR y=#{y}, #{ranges.size} ranges"
      ranges = ranges.sort_by {|r| [r.begin, r.end]}
      # Merge all the ranges
      puts "MERGING RANGES FOR y=#{y}, #{ranges.size} ranges"
      ranges.each do |r2|
        if new_ranges.size == 0
          new_ranges << r2
        else
          r1_idx = new_ranges.size - 1
          r1 = new_ranges.last
          if r2.begin > r1.end + 1
            new_ranges << r2
          else
            if r1.cover?(r2)
              # throw away r2
            elsif r2.end > r1.end
              new_ranges[r1_idx] = (r1.begin..r2.end)
            end
          end
        end
      end
      new_ranges.each do |range|
        #puts "DEAD: #{y}:#{range}"
        @grid.add_value(range.begin, y, DZ_BEGIN)
        @grid.add_value(range.end, y, DZ_END)
      end
    end
  end
  def run
    load_data
    puts "Loaded #{@sensors.size} sensors"
    puts "X: #{@grid.xmin}->#{@grid.xmax} Y: #{@grid.ymin}->#{@grid.ymax}"
    puts "GRID: #{@grid.rows} rows, #{@grid.cols} columns"
    #@sensors.each do |s,b|
    #  dist = s.taxi_dist(b)
    #  @grid.add_value(s.x, s.y - dist, DZ)
    #  @grid.add_value(s.x, s.y + dist, DZ)
    #end
    @grid.draw_compact
    #add_dead_zones
    #@grid.draw

    #s11, b11 = @sensors[11]
    #dist = s11.taxi_dist(b11)
    #puts "SENSOR 11: #{s11} BEACON: #{b11} DIST: #{dist}=#{b11.taxi_dist(s11)}"
    #puts "VALUE AT #{b11}: #{@grid.value_at(b11.x, b11.y)}"

    #y = 10
    y = 2_000_000
    count_occ = 0
    p = Point.new(0,y)
    pb = ProgressBar.create(:total => (@grid.xmax - @grid.xmin + 1), :title => "Points")
    @grid.xmin.upto(@grid.xmax) do |x|
      p.x = x
      @sensors.each do |s, b|
        dist = s.taxi_dist(b)
        if s.taxi_dist(p) <= dist && (@grid.value_at(x,y) & BEACON) == 0
          count_occ += 1
          break
        end
      end
      pb.increment
    end
    puts
    puts "Part1: For y=#{y}, #{count_occ} of #{@grid.xmax - @grid.xmin + 1} spots are blocked"
  end
end

if __FILE__ == $PROGRAM_NAME
  solution = Day15.new
  solution.run
end
