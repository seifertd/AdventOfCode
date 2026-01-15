require '../../common/point'

class Solution
  def parse
    @maps = input.map do |line|
      line.split(//).map(&:to_sym)
    end
  end
  def follow(map)
    visited = Set.new
    curr = Point.new(0.0)
    visited << curr
    map.each do |dir|
      curr = curr.move(dir)
      visited << curr
    end
    visited.size
  end
  def part1
    parse
    houses = nil
    @maps.each do |map|
      houses = follow(map)
      debug { "Map: #{map.join} Visited: #{houses}\n" }
      houses
    end
    houses
  end
  def robo_follow(map)
    visited = Set.new
    santa = Point.new(0.0)
    robot = Point.new(0.0)
    visited << santa
    map.each_slice(2) do |sdir, rdir|
      santa = santa.move(sdir)
      robot = robot.move(rdir) if rdir
      visited << santa
      visited << robot
    end
    visited.size
  end
  def part2
    parse
    houses = nil
    @maps.each do |map|
      houses = robo_follow(map)
      debug { "Map: #{map.join} Visited: #{houses}\n" }
      houses
    end
    houses
  end
  def input
    if block_given?
      ARGF.each_line do |line|
        line.chomp!
        yield(line)
      end
    else
      return to_enum(:input)
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
