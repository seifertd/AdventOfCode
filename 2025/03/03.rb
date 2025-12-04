class Solution
  def part1
    joltage = 0
    input do |line|
      nums = line.split(//).map(&:to_i)
      sorted = nums.sort.reverse
      max_ind = 0
      tens = 0
      tens_ind = 0
      loop do
        tens = sorted[max_ind]
        tens_ind = nums.index(tens)
        debug { "TRY: tens: #{tens} ind: #{tens_ind} nums.len: #{nums.length}\n" }
        break if tens_ind != nums.length - 1
        max_ind += 1
      end
      sorted = nums[tens_ind+1..-1].sort.reverse
      debug { "tens:#{tens} tens_ind:{tens_ind} new sorted: #{sorted.inspect}\n" }
      ones = sorted.first
      jolt = tens * 10 + ones
      joltage += jolt
      debug { "bank: #{line} sorted: #{sorted.inspect} jolt: #{jolt} joltage: #{joltage} nums[-2] = #{nums[-2].inspect}\n" }
    end
    joltage
  end
  def part2
    joltage = 0
    input do |line|
      nums = line.split(//).map(&:to_i)
      jolt = []
      while nums.size > 0
        curr = jolt.last
        if curr && curr < nums.first
          while curr && curr < nums.first && jolt.size + nums.size > 12
            jolt.pop
            curr = jolt.last
          end
          jolt << nums.shift
        else
          jolt << nums.shift
        end
        debug { "nums: #{nums.join} jolt: #{jolt.join}\n" }
      end
      # Prune down to 12
      jolt = jolt[0,12]
      joltage += jolt.join.to_i
      debug { "Line: #{line} Jolt: #{jolt.join} Joltage: #{joltage} nums: #{nums.join}\n" }
    end
    joltage
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
