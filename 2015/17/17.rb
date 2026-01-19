class Solution
  def parse
    input do |line|
      if !@containers
        @containers = line.split(",").map(&:to_i)
      else
        @total = line.to_i
      end
    end
  end
  def part1
    parse
    debug { "Containers: #{@containers} Total: #{@total}\n" }
    count = 0
    find_combos(@containers, @total) do |combo|
      debug { "FOUND COMBO: #{combo}\n" }
      count += 1
    end
    count
  end
  def find_combos(containers, target, current = [], level = 1)
    if target == 0
      # We reached the target with current
      yield(current)
      return
    end

    if containers.size == 0
      # No more containers to try
      return
    end

    if containers.sum < target
      # using all remaining containers won't get us to the target
      return
    end

    0.upto(containers.length-1) do |ci|
      next if containers[ci] > target
      current << containers[ci]
      new_containers = containers[(ci+1)..-1]
      find_combos(new_containers, target - containers[ci], current, level + 1) do |combo|
        yield combo
      end
      current.pop
    end
  end
  def part2
    parse
    debug { "Containers: #{@containers} Total: #{@total}\n" }
    min_number = 1_000_000
    min_combos = 0
    find_combos(@containers, @total) do |combo|
      debug { "FOUND COMBO: #{combo}\n" }
      if combo.size < min_number
        min_number = combo.size
        min_combos = 1
      elsif combo.size == min_number
        min_combos += 1
      end
    end
    debug { "Minimum number of containers: #{min_number}, combinations: #{min_combos}\n" }
    min_combos
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
