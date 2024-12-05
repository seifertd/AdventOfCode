require 'set'
class Solution
  attr_reader :rules, :updates
  def initialize
    @rules = Hash.new {|h,k| h[k] = Set.new}
    @updates = []
  end
  def parse_input
    parsing_rules = true
    input do |line|
      if line == ""
        parsing_rules = false
        next
      end
      if parsing_rules
        before, after = line.split('|').map(&:to_i)
        @rules[before] << after
      else
        @updates << line.split(',').map(&:to_i)
      end
    end
  end
  def update_bad(upd)
    upd_bad = false
    idx = 0
    while idx < upd.size && !upd_bad
      before = upd[idx]
      #debug "BEFORE: idx=#{idx} #{before}\n"
      if !@rules.has_key?(before)
        #debug "ERROR? RULES DON'T CONTAIN BEFORE VALUE #{before}, SKIP?\n"
        next
      else
        rule = @rules[before]
        #debug "RULE: #{rule.inspect}\n"
        rest = upd[(idx+1)..-1]
        if rest.any? { |after| !@rules[after].empty? && @rules[after].include?(before) }
          #debug "BAD: REST: #{rest.inspect}, RRULES: #{rest.map{|a| @rules[a].inspect}.join(", ")}\n"
          upd_bad = true
          break
        end
      end
      break if upd_bad
      idx += 1
    end
    upd_bad
  end
  def part1
    parse_input
    total = 0
    @updates.each do |upd|
      debug "ORDERING: #{upd.inspect}\n"
      if !update_bad(upd)
        debug "UPDATE #{upd.inspect} is in the right order\n"
        total += upd[upd.size/2]
      end
    end
    total
  end
  def part2
    parse_input
    total = 0
    @updates.each do |upd|
      if update_bad(upd)
        debug "ORDERING BAD: #{upd.inspect}\n"
        sorted_upd = upd.sort do |a, b|
          if @rules.has_key?(a) && @rules[a].include?(b)
            -1
          elsif @rules.has_key?(b) && @rules[b].include?(a)
            1
          else
            0
          end
        end
        debug "SORTED #{sorted_upd.inspect}\n"
        total += sorted_upd[sorted_upd.size/2]
      end
    end
    total
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield line
    end
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
    puts "Usage: [DEBUG=true] ruby #{__FILE__} [part1|part2] <INPUTFILE>"
    puts "  - use DEBUG=true to show detailed debug output"
    puts "    but be careful doing this with the actual puzzle input"
    puts "    best used with the sample input"
    puts "  - first arg is either part1 or part2"
    puts "  - second arg is the sample data (or you can just pipe it in)"
  end
end
