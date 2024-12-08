require 'set'
require_relative '../../common/point'

class Solution
  def parse_grid
    @grid = []
    @amap = Hash.new{|h,k| h[k] = Set.new}
    input do |line, y|
      @grid << line.split(//)
      @grid.last.each.with_index do |c, x|
        if c != '.'
          @amap[c] << Point.new(x,y)
        end
      end
    end
    return [@grid, @amap]
  end
  def print_grid(grid, antinodes)
    antinodes.each do |p|
      grid[p.y][p.x] = '#'
    end
    grid.each do |row|
      puts row.join
    end
  end
  def part1
    grid, amap = parse_grid
    antinodes = Set.new
    amap.each do |char, set|
      set.to_a.combination(2).each do |p1, p2|
        diff = p1.dist_comps(p2)
        np1 = p1.add(diff.neg)
        np2 = p2.add(diff)
        antinodes << np1 if np1.x >= 0 && np1.y >= 0 && np1.x < grid[0].size && np1.y < grid.size
        antinodes << np2 if np2.x >= 0 && np2.y >= 0 && np2.x < grid[0].size && np2.y < grid.size
      end
    end
    if ENV['DEBUG']
      print_grid(grid, antinodes)
    end
    antinodes.size
  end
  def part2
    grid, amap = parse_grid
    antinodes = Set.new
    amap.each do |char, set|
      set.to_a.combination(2).each do |p1, p2|
        diff = p1.dist_comps(p2)
        negdiff = diff.neg
        np1 = Point.new(p2.x, p2.y)
        loop do
          np1 = np1.add(diff.neg)
          break if !(np1.x >= 0 && np1.y >= 0 && np1.x < grid[0].size && np1.y < grid.size)
          antinodes << np1
        end
        np2 = Point.new(p1.x, p1.y)
        loop do
          np2 = np2.add(diff)
          break if !(np2.x >= 0 && np2.y >= 0 && np2.x < grid[0].size && np2.y < grid.size)
          antinodes << np2
        end
      end
    end
    if ENV['DEBUG']
      print_grid(grid, antinodes)
    end
    antinodes.size
  end
  def input
    ARGF.each_line.with_index do |line, idx|
      line.chomp!
      yield(line, idx)
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
