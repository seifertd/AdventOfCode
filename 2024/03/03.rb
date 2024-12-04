require 'strscan'

class Solution
  def part1
    instructions = StringScanner.new ARGF.read
    mulre = /mul\((\d+),(\d+)\)/
    result = 0
    while nums = instructions.scan_until(mulre)
      result += instructions.captures.map(&:to_i).inject(&:*)
    end
    result
  end

  def part2
    enabled = true
    cmdre = /(mul)\((\d+),(\d+)\)|(do)\(\)|(don't)\(\)/
    result = 0
    instructions = StringScanner.new ARGF.read
    while instructions.scan_until(cmdre)
      cmd = instructions.captures
      if enabled
        if cmd[0] == 'mul'
          result += cmd[1].to_i * cmd[2].to_i
        elsif cmd[4] == "don't"
          enabled = false
        end
      else
        if cmd[3] == 'do'
          enabled = true
        end
      end
      debug "ENABLED: #{enabled} CMD: #{cmd.inspect} SUM: #{result}\n"
    end
    result
  end

  def debug(msg)
    print(msg) if ENV['DEBUG']
  end

  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
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
