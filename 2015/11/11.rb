require './password'

class Solution
  def next_valid(pw)
    while true
      pw = pw.smart_inc
      break if !pw.invalid?
    end
    pw
  end
  def part1
    pw = nil
    input do |str|
      pw = Password.new(str)
      debug { "Check #{pw}: INVALID? #{pw.invalid?}\n" }
      pw = next_valid(pw)
      debug { "Next valid: #{pw}: INVALID? #{pw.invalid?}\n" }
    end
    pw.to_s
  end
  def part2
    pw = input.to_a.join
    pw = Password.new(pw)
    debug { "Original: #{pw}: INVALID? #{pw.invalid?}\n" }
    pw = next_valid(pw)
    debug { "Reset 1: #{pw}: INVALID? #{pw.invalid?}\n" }
    pw = next_valid(pw)
    debug { "Reset 2: #{pw}: INVALID? #{pw.invalid?}\n" }
    pw.to_s
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
