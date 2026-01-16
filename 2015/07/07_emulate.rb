class Solution
  def parse
    @operations = []
    @registers = {}
    input do |line|
      oper, target_reg = line.split(" -> ")
      target_reg = target_reg.to_sym
      if oper =~ /(\w+) (AND|OR|LSHIFT|RSHIFT) (\w+)/
        lhs = $1 
        rhs = $3
        @operations << [target_reg, $2, lhs, rhs]
      elsif oper =~ /NOT (\w+)/
        @operations << [target_reg, 'NOT', $1.to_sym]
      elsif oper =~ /(\d+)/
        @registers[target_reg] = $1.to_i
      else
        @operations << [target_reg, 'EQ', oper.to_sym]
      end
    end
  end
  def run
    while @operations.size > 0
      o = @operations.shift
      debug { " -> #{o}\n" }
      reg = o[0]
      lhs = o[2]
      if lhs =~ /\d+/
        lhs = lhs.to_i
      else
        if !@registers[lhs.to_sym]
          @operations << o
          next
        end
        lhs = @registers[lhs.to_sym]
      end
      rhs = o[3]
      if !rhs.nil?
        if rhs =~ /\d+/
          rhs = rhs.to_i
        else
          if !@registers[rhs.to_sym]
            @operations << o
            next
          else
            rhs = @registers[rhs.to_sym]
          end
        end
      end
      case o[1]
      when 'NOT'
        @registers[reg] = lhs ^ ((1 << 16) - 1)
      when 'EQ'
        @registers[reg] = lhs
      when 'LSHIFT'
        @registers[reg] = lhs << rhs
      when 'RSHIFT'
        @registers[reg] = lhs >> rhs
      when 'AND'
        @registers[reg] = lhs & rhs
      when 'OR'
        @registers[reg] = lhs | rhs
      else
        raise "UNKNOWN OPERATION #{o[1]}"
      end
    end
  end
  def part1
    parse
    debug { "REGISTERS: #{@registers.inspect}\n" }
    debug { "OPERATIONS: #{@operations.inspect}\n" }
    run
    debug { "RUN: #{@registers.inspect}\n" }
    @registers[:a]
  end
  def part2
    parse
    if ENV['OVERRIDE']
      @registers[:b] = ENV['OVERRIDE'].to_i
    else
       raise "Provide OVERRIDE=n environment variable"
    end
    run
    @registers[:a]
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
