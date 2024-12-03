class Solution
  def part1
    safe = 0
    read_input do |line|
      levels = line.split(/\s+/).map(&:to_i)
      if levels_are_safe(levels)
        safe += 1
      end
      puts if ENV['DEBUG']
    end
    safe
  end
  def levels_are_safe(levels)
    diffs = levels.each_cons(2).map do |pair|
      pair[1] - pair[0]
    end
    print "#{levels.inspect} #{diffs.inspect}: " if ENV['DEBUG']
    num_pos_diffs = diffs.count{|n| n > 0}
    num_neg_diffs = diffs.count{|n| n < 0}
    if diffs.all?{|d| d.abs <= 3 && d != 0 } && (num_pos_diffs == 0 || num_neg_diffs == 0)
      print " SAFE" if ENV['DEBUG']
      true
    else
      print " NOT SAFE" if ENV['DEBUG']
      false
    end
  end
  def part2
    safe = 0
    read_input do |line|
      levels = line.split(/\s+/).map(&:to_i)
      if levels_are_safe(levels)
        safe += 1
      else
        levels.size.times do |idx|
          new_levels = levels.dup
          new_levels.delete_at(idx)
          if levels_are_safe(new_levels)
            safe += 1
            break
          end
        end
      end
      puts if ENV['DEBUG']
    end
    safe
  end
  def read_input
    ARGF.each_line do |line|
      line.chomp!
      yield line
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
    puts "Usage: ruby #{__FILE__} [part1|part2] <INPUTFILE>"
  end
end
