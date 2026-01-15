require 'digest'

class Solution
  def solve(prefix = '00000')
    ans = nil
    input do |key|
      n = 1
      while true
        str = "#{key}#{n}"
        break if Digest::MD5.hexdigest(str).start_with?(prefix)
        n += 1
      end
      debug { "KEY: #{key} N: #{n}\n" }
      ans = n
    end
    ans
  end
  def part1
    solve('00000')
  end
  def part2
    solve('000000')
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
