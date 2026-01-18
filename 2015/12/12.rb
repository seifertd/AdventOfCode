require 'json'

class Solution
  def part1
    ans = nil
    input do |line|
      ans = line.scan(/-?\d+/).map(&:to_i).sum
      debug { "COUNT: #{ans} LINE: #{line}\n" }
    end
    ans
  end
  def count_obj(obj)
    if obj.is_a?(Array)
      obj.sum{|c| count_obj(c)}
    elsif obj.is_a?(Hash)
      unless obj['red'] || obj.values.include?("red")
        obj.values.sum{|c| count_obj(c) }
      else
        0
      end
    elsif obj.is_a?(Numeric)
      obj
    else
      0
    end
  end
  def part2
    ans = nil
    input do |line|
      obj = JSON.parse(line)
      ans = count_obj(obj)
      debug { "COUNT: #{ans} OBJECT: #{line}\n" }
    end
    ans
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
