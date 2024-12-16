Factors = Struct.new(:c1, :c2, :c3, :c4, :t1, :t2) do
  def to_s
    "(c1=#{c1},c2=#{c2},c3=#{c3},c4=#{c4},t1=#{t1},t2=#{t2})"
  end
end
class Solution


  def parse_eqs
    eqs = []
    input do |line|
      if line.start_with?("Button A")
        eqs << Factors.new
        md = line.match(/X\+(\d+), Y\+(\d+)/)
        eqs.last.c1 = md[1].to_f
        eqs.last.c3 = md[2].to_f
      elsif line.start_with?("Button B")
        md = line.match(/X\+(\d+), Y\+(\d+)/)
        eqs.last.c2 = md[1].to_f
        eqs.last.c4 = md[2].to_f
      elsif line.start_with?("Prize:")
        md = line.match(/X=(\d+), Y=(\d+)/)
        eqs.last.t1 = md[1].to_f
        eqs.last.t2 = md[2].to_f
      end
    end
    eqs
  end
  def calc_b(eq)
    (eq.t2 - (eq.c3*eq.t1/eq.c1)) / (eq.c4 - (eq.c2*eq.c3/eq.c1))
  end
  def calc_a(eq, b)
    a = ((eq.t1 - eq.c2*b) / eq.c1).round
  end
  def part1
    ta = 3
    tb = 1
    eqs = parse_eqs
    total_tokens = 0
    eqs.each do |eq|
      b = calc_b(eq)
      a = calc_a(eq, b)
      b = b.round
      debug "EQ: #{eq} a=#{a} b=#{b}"
      if a <= 100 && b <= 100 && a >= 0 && b >= 0
        test_t1 = (eq.c1 * a + eq.c2 * b).round
        test_t2 = (eq.c3 * a + eq.c4 * b).round
        if test_t1 != eq.t1.round || test_t2 != eq.t2.round
          debug " NO MATCH: test t1: #{test_t1} test t2: #{test_t2}"
        else 
          tokens = a * ta + b * tb
          debug " tokens: #{tokens}"
          total_tokens += tokens
        end
      end
      debug "\n"
    end
    total_tokens
  end
  def part2
    ta = 3
    tb = 1
    eqs = parse_eqs
    total_tokens = 0
    eqs.each do |eq|
      eq.t1 += 10000000000000
      eq.t2 += 10000000000000
      b = calc_b(eq)
      a = calc_a(eq, b)
      b = b.round
      debug "EQ: #{eq} a=#{a} b=#{b}"
      if a >= 0 && b >= 0
        test_t1 = (eq.c1 * a + eq.c2 * b).round
        test_t2 = (eq.c3 * a + eq.c4 * b).round
        if test_t1 != eq.t1.round || test_t2 != eq.t2.round
          debug " NO MATCH: test t1: #{test_t1} test t2: #{test_t2}"
        else 
          tokens = a * ta + b * tb
          debug " tokens: #{tokens}"
          total_tokens += tokens
        end
      end
      debug "\n"
    end
    total_tokens
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
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
