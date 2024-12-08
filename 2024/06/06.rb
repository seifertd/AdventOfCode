require_relative '../../common/point'
require 'set'

class Solution
  DY = [-1, 0, 1, 0]
  DX = [0, 1, 0, -1]
  def check(grid, x, y, ox=-1, oy=-1, d=0)
    rows = grid.size
    cols = grid[0].size
    seen = Set.new([Point.new(x,y,d)])
    loop do
      y += DY[d]; x += DX[d]
      return seen if !(0 <= x && x < cols && 0 <= y && y < cols)
      if grid[y][x] == '#' || (x == ox && y == oy)
        y -= DY[d]; x -= DX[d]
        d = (d + 1) % 4
      end
      p = Point.new(x, y, d)
      return nil if seen.include?(p)
      seen << p
    end
  end
  def parse_grid
    @grid = []
    @gx = nil
    @gy = nil
    rows = 0
    input do |line|
      @grid << line.split(//) 
      if @grid.last.include?('^')
        @gx = @grid.last.index('^')
        @gy = rows
      end
      rows += 1
    end
    throw "NO GUARD gx:#{@gx},gy:#{@gy}" if @gx.nil? || @gy.nil?
    return [@grid, @gx, @gy]
  end
  def part1
    grid, gx, gy = parse_grid
    path = check(grid, gx, gy)
    path.map{|p| Point.new(p.x, p.y)}.uniq.count
  end
  def part2
    blocks  = 0
    grid, gx, gy = parse_grid
    grid.size.times do |oy|
      grid[0].size.times do |ox|
        if grid[oy][ox] == '.'
          if !check(grid, gx, gy, ox, oy)
            blocks  += 1
          end
        end
      end
    end
    blocks
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
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
