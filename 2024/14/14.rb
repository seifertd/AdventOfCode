require_relative "../../common/point"
class Robot
  attr_reader :pos, :vel
  def initialize(p, v)
    @pos = p
    @vel = v
  end
  def to_s
    "R:[p=#{pos} v=#{vel}]"
  end
end

class Solution
  def print_grid(robots, rows, cols, char = nil)
    rows.times do |y|
      cols.times do |x|
        p = Point.new(x,y)
        count = robots.count{|r| r.pos == p}
        if count > 0
          print "#{char || count}"
        else
          print " "
        end
      end
      puts
    end
  end
  def parse_bots
    if ARGV == ["sample.txt"]
      rows = 7
      cols = 11
    else
      rows = 103
      cols = 101
    end
    robots = []
    input do |line|
      pos, vel = line.split(" ")
      p = Point.new(*pos[2..-1].split(",").map(&:to_i))
      v = Point.new(*vel[2..-1].split(",").map(&:to_i))
      robots << Robot.new(p,v)
    end
    [rows, cols, robots]
  end
  def part1
    rows, cols, robots = parse_bots
    debug "Read #{robots.size} robots\n"
    if ENV['DEBUG']
      print_grid(robots, rows, cols)
    end
    100.times do |sec|
      robots.each do |r|
        r.pos.x = (r.pos.x + r.vel.x) % cols
        r.pos.y = (r.pos.y + r.vel.y) % rows
      end
    end
    quads = Array.new(4,0)
    midx = cols / 2
    midy = rows / 2
    robots.each do |r|
      if r.pos.x < midx
        if r.pos.y < midy
          quads[0] += 1
        elsif r.pos.y > midy
          quads[2] += 1
        end
      elsif r.pos.x > midx
        if r.pos.y < midy
          quads[1] += 1
        elsif r.pos.y > midy
          quads[3] += 1
        end
      end
    end
    debug "#{quads.inspect}\n"
    quads.inject(&:*)
  end
  def fast_print_grid(robots, char)
    print "\033[2J"
    robots.each do |r|
      print "\033[#{r.pos.y};#{r.pos.x}H#{char}"
    end
  end
  def detect_straight_lines(robots)
    sorted_by_y = robots.sort_by{|r| [r.pos.y, r.pos.x]}
    in_a_row = 0
    curr = nil
    trail = []
    while in_a_row < 10 && r = sorted_by_y.shift
      if in_a_row == 0
        curr = r
        trail << r
        in_a_row = 1
      elsif r.pos.y == curr.pos.y && r.pos.x == curr.pos.x + 1
        in_a_row += 1
        trail << r
        if in_a_row >= 10
          debug "DETECTED STRAIGHT VERTICAL LINE ENDING AT #{curr}, LENGTH: #{in_a_row}: #{trail.map(&:pos).inspect}\n"
          return true
        end
        curr = r
      else
        in_a_row = 1
        curr = r
        trail = [r]
      end
    end
    return false
  end
  def part2
    iter = 0
    rows, cols, robots = parse_bots
    100000.times do |sec|
      robots.each do |r|
        r.pos.x = (r.pos.x + r.vel.x) % cols
        r.pos.y = (r.pos.y + r.vel.y) % rows
      end
      iter += 1
      if detect_straight_lines(robots)
        if ENV['DEBUG']
          fast_print_grid(robots, "█")
          print "\033[#{rows};0HIteration: #{iter}\n"
        end
        return iter
      end
    end
    -1
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
