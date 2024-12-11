class Solution
  def blink(stones)
    idx = 0
    while idx < stones.size
      if stones[idx] == 0
        stones[idx] = 1
        idx += 1
      elsif stones[idx] == 1
        stones[idx] = 2024
        idx += 1
      elsif (digits = "#{stones[idx]}".length).even?
        num = stones[idx]
        fact = 10 ** (digits/2)
        stones[idx] =  num / fact
        stones.insert(idx + 1, num % fact)
        idx += 2
      else
        stones[idx] *= 2024
        idx += 1
      end
    end
  end
  def part1
    stones = ARGF.read.split(" ").map(&:to_i)
    (ENV['ITERS'] || 25).to_i.times do |blk|
      blink(stones)
      debug "BLINK: #{blk + 1}: number stones: #{stones.size}\n"
    end
    stones.size
  end
  def blink2(stones)
    newstones = Hash.new {|h,k| h[k] = 0 }
    stones.each do |num, count|
      if num == 0
        newstones[1] += count
      elsif num == 1
        newstones[2024] += count
      elsif (digits = "#{num}".length).even?
        fact = 10 ** (digits/2)
        newstones[num / fact] += count
        newstones[num % fact] += count
      else
        newstones[num*2024] += count
      end
    end
    newstones
  end
  def part2
    stones = Hash.new {|h,k| h[k] = 0}
    ARGF.read.split(" ").map(&:to_i).each do |num|
      stones[num] = 1
    end
    (ENV['ITERS'] || 75).to_i.times do |blk|
      stones = blink2(stones)
      debug "BLINK: #{blk + 1}: unique stones: #{stones.size} total stones: #{stones.values.sum}\n"
    end
    stones.values.sum
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
