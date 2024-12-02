class Solution
  def part1
    l1 = []
    l2 = []
    ARGF.each_line do |line|
      line.strip!
      nums = line.split(/\s+/).map(&:to_i)
      raise "Bad data, couldn't find two ints: #{line}" if nums.size != 2
      l1 << nums[0]
      l2 << nums[1]
    end
    l1.sort!
    l2.sort!
    l1.zip(l2).inject(0) do |sum, pair|
      sum += (pair[0] - pair[1]).abs
    end
  end
  def part2
    l1 = []
    l2 = Hash.new {|h,k| h[k] = 0}
    ARGF.each_line do |line|
      line.strip!
      nums = line.split(/\s+/).map(&:to_i)
      raise "Bad data, couldn't find two ints: #{line}" if nums.size != 2
      l1 << nums[0]
      l2[nums[1]] += 1
    end
    l1.inject(0) do |score, num|
      score += num * l2[num]
    end
  end
end

if __FILE__ == $0
  solution = Solution.new
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
