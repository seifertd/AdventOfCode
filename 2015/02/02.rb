require '../../common/point'

class Solution
  def parse
    @boxes = input.map do |line|
      Point.new(*line.split('x').map(&:to_i))
    end
  end
  def part1
    parse
    debug { "Boxes: #{@boxes.inspect}\n" }
    @boxes.map do |box|
      sides = [box.x * box.y, box.y * box.z, box.z * box.x]
      a = sides.map{|a| 2 * a}.sum + sides.min
      debug { "Box: #{box} Sides: #{sides} A: #{a}\n" }
      a
    end.sum
  end
  def part2
    parse
    @boxes.map do |box|
      perims = [2 * box.x + 2 * box.y, 2 * box.y + 2 * box.z, 2 * box.z + 2 * box.x]
      v = box.x * box.y * box.z
      ribbon = perims.min + v
      debug { "Box: #{box} Perims: #{perims} V: #{v} ribbon: #{ribbon}\n" }
      ribbon
    end.sum
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
