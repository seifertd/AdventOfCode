class Solution
  def part1
    result = nil
    input do |line|
      result = line.count('(') - line.count(')')
      debug { "LINE: #{line} Result: #{result}\n" }
    end
    result
  end
  def part2
    pushes = nil
    input do |line|
      pushes = line
    end
    floor = 0
    result = nil
    idx = 0
    0.upto(pushes.length - 1) do |idx|
      b = pushes[idx]
      result = idx + 1
      floor += b == '(' ? 1 : -1
      break if floor == -1
    end
    result
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
