class Solution
  def part1
    total = 50
    password = 0
    self.input do |line|
      mult = line[0] == 'L' ? -1 : 1
      amt = line[1..-1].to_i
      total = (total + mult*amt) % 100
      debug { "MULT: #{mult} AMT: #{amt} NEW TOTAL: #{total}\n" }
      password += 1 if total == 0
    end
    debug { "PASSWORD: #{password}\n" }
    password
  end
  def part2
    total = 50
    password = 0
    self.input do |line|
      mult = line[0] == 'L' ? -1 : 1
      amt = line[1..-1].to_i
      oldtotal = total
      amt.times do
        total = (total + mult) % 100
        password += 1 if total == 0
      end
      debug { "MULT: #{mult} AMT: #{amt} OLD: #{oldtotal} NEW TOTAL: #{total} password: #{password}\n" }
    end
    debug { "PASSWORD: #{password}\n" }
    password
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
