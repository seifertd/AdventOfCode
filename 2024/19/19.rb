class Solution
  def parse_data
    patterns = nil
    designs = nil
    input do |line|
      next if line == ''
      if patterns.nil?
        patterns = line.split(", ")
        next
      end
      if designs.nil?
        designs = []
      end
      designs << line
    end
    [patterns, designs]
  end
  def count_setups(patterns, design, cache = {})
    if design.empty?
      return 1
    end
    if count = cache[design]
      return count
    end
    matches = 0
    patterns.each do |pat|
      if design.start_with?(pat)
        matches += count_setups(patterns, design.sub(/^#{pat}/, ''), cache)
      end
    end
    cache[design] = matches
    matches
  end
  def part1
    patterns, designs = parse_data
    debug { "PATTERNS: #{patterns.inspect}\n" }
    debug { "DESIGNS: #{designs.inspect}\n" }
    designs.count do |design|
      count = count_setups(patterns, design, {})
      debug { "DESIGN: #{design} SETUPS: #{count}\n" }
      count > 0
    end
  end
  def part2
    patterns, designs = parse_data
    cache = {}
    designs.inject(0) do |sum, design|
      count = count_setups(patterns, design, cache);
      sum += count
      debug { "DESIGN: #{design} COUNT: #{count} SUM: #{sum}\n" }
      sum
    end
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
