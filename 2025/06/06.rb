class Solution
  def part1
    probs = []
    input do |line|
      probs << line.strip.split(/ +/)
    end
    debug { "PROBS: #{probs.inspect}\n" }
    sum = 0
    probs.first.size.times do |col|
      op = probs.last[col].to_sym
      operands = probs[0..-2].map {|r| r[col].to_i}
      ans = operands.inject(op)
      debug { "operands: #{operands.inspect} op: #{op.inspect} ans: #{ans}\n" }
      sum += ans
    end
    sum
  end
  def part2
    probs = []
    input do |line|
      probs << line.split(//)
    end
    ops = probs.last
    op = nil
    operands = []
    sum = 0
    debug { "OPS: #{ops.inspect}\n" }
    ops.each.with_index do |opc, col|
      if opc != ' '
        # calculate result of last collected number
        if !op.nil?
          ans = operands.inject(op) 
          debug { "operands: #{operands.inspect} op: #{op.inspect} ans: #{ans}\n" }
          sum += ans
        end
        op = opc.to_sym
        operands = []
      end
      arg = probs[0..-2].map {|row| row[col]}.join.strip
      if !arg.empty?
        operands << arg.to_i
      end
    end
    # collect last result
    if !op.nil?
      ans = operands.inject(op) 
      debug { "operands: #{operands.inspect} op: #{op.inspect} ans: #{ans}\n" }
      sum += ans
    end
    sum
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
