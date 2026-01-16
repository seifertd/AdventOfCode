class Solution
  def eval_node(node, memo = {})
    if memo.has_key?(node)
      memo[node]
    else
      expr = @nodes[node]
      raise "No expression for node #{node.inspect}" if expr.nil?
      memo[node] = eval_expr(expr, memo)
    end
  end
  def eval_const_or_node(val, memo)
    debug { "EVAL NODE OR CONST: #{val.inspect}\n" }
    if val =~ /\d+/ 
      val.to_i
    else
      eval_node(val.to_sym, memo)
    end
  end
  def eval_expr(expr, memo)
    debug { "EVAL EXPR #{expr}\n" }
    lhs, op, rhs = expr.split(" ")
    if op.nil? && rhs.nil?
      eval_const_or_node(lhs, memo)
    elsif rhs.nil?
      # NOT
      lhs, op = op, lhs
      raise "Unknown operation #{op}" if op != 'NOT'
      eval_const_or_node(lhs, memo) ^ ((1 << 16) - 1)
    else
      lhs = eval_const_or_node(lhs, memo)
      rhs = eval_const_or_node(rhs, memo)
      case op
      when 'LSHIFT'
        lhs << rhs
      when 'RSHIFT'
        lhs >> rhs
      when 'AND'
        lhs & rhs
      when 'OR'
        lhs | rhs
      else
        raise "Unknown operation #{op}"
      end
    end
  end
  def parse
    @nodes = {}
    input do |line|
      expr, name = line.split(" -> ")
      @nodes[name.to_sym] = expr
    end
  end
  def part1
    parse
    eval_node(:a)
  end
  def part2
    parse
    memo = {}
    if ENV['OVERRIDE']
      memo[:b] = ENV['OVERRIDE'].to_i
    else
       raise "Provide OVERRIDE=n environment variable"
    end
    ans = eval_node(:a, memo)
    debug { "MEMO: #{memo.inspect}\n" }
    ans
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
