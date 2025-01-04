class Solution
  def parse_input
    objs = ARGF.read.split("\n\n").map {|l| l.split("\n").map(&:chars)}
    keys, locks = objs.partition do |obj|
      obj[-1].all?{|c| c == '#'}
    end
    keys = keys.map do |k|
      k.transpose.map{|l| l.reverse.rindex('#')}
    end
    locks = locks.map do |l|
      l.transpose.map{|l| l.rindex('#')}
    end
    return [locks, keys]
  end
  def part1
    locks, keys = parse_input
    debug { "LOCKS: #{locks.count} UNIQ: #{locks.uniq.count}\n" }
    debug { "KEYS: #{keys.count} UNIQ: #{keys.uniq.count}\n" }
    debug { "KEY1: #{keys.first.inspect}\n"}
    count = 0
    keys.uniq.each do |key|
      locks.uniq.each do |lock|
        fits = key.zip(lock).map(&:sum)
        count += 1 if fits.all?{|f| f <= 5 }
        #debug { "KEY: #{key.inspect} LOCK: #{lock.inspect} FITS: #{fits.inspect}: COUNT: #{count}\n" }
      end
    end
    count
  end
  def part2
    raise "part2 solution not implemented"
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
