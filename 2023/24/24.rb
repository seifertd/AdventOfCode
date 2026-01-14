require '../../common/point'
require '../../common/gaussian'

class Solution
  def parse
    @stones = []
    input do |line|
      pos, vel = line.split(" @ ")
      @stones << [Point.new(*pos.split(", ").map(&:to_i)), Point.new(*vel.split(", ").map(&:to_i))]
    end
  end
  def part1
    parse
    min = (ENV['MIN'] || 7).to_i
    max = (ENV['MAX'] || 17).to_i
    debug { "MIN: #{min} MAX: #{max} STONES: #{@stones}\n" }
    count = 0
    @stones.combination(2).each do |s1, s2|
      s1_p = s1[0]
      s1_v = s1[1]
      s2_p = s2[0]
      s2_v = s2[1]
      system = [
        [s1_v.x, -s2_v.x, s2_p.x - s1_p.x],
        [s1_v.y, -s2_v.y, s2_p.y - s1_p.y]
      ]
      debug { "S1: #{s1} S2: #{s2}\n" }
      begin
        Gaussian.solve(system)
        debug { "SOLUTION: #{system}\n" }
        if system[0][2] > 0 && system[1][2] > 0
          x = s1_p.x + system[0][2] * s1_v.x
          y = s1_p.y + system[0][2] * s1_v.y
          debug { "x=#{x}, y=#{y}\n" }
          count += 1 if x.between?(min,max) && y.between?(min,max)
        else
          debug { "System instersects in the past for one or more stones\n" }
        end
      rescue Exception => e
        debug { "Unsolvable system: #{system}\n" }
      end
    end
    count
  end

  def find_sequence(sequences)
    return nil if sequences.empty?
    
    moduli = sequences.map { |a| a.last }
    
    candidates = (-300..300).to_a.reject { |p| p == 0 }
    
    best_solution = nil
    best_abs_i = Float::INFINITY
    
    candidates.each do |p|
      result = try_p(sequences, p)
      if result && result[0].abs < best_abs_i
        best_solution = result
        best_abs_i = result[0].abs
      end
    end
    
    best_solution
  end

  def try_p(sequences, p)
    # Separate sequences into two groups:
    # 1. Those where M = P (must have I = C)
    # 2. Those where M ≠ P (use CRT)
    
    matching_sequences = sequences.select { |c, m| m == p }
    other_sequences = sequences.reject { |c, m| m == p }
    
    # If we have matching sequences, they all must agree on I
    if matching_sequences.any?
      required_i_values = matching_sequences.map { |c, m| c }.uniq
      if required_i_values.length > 1
        # Conflicting requirements for I
        return nil
      end
      required_i = required_i_values[0]
      
      # Check if this I works for all other sequences
      if other_sequences.empty?
        # All sequences have M = P, so just return the required I
        return [required_i, p]
      end
      
      # Verify required_i works for other sequences
      if verify_solution(sequences, required_i, p)
        return [required_i, p]
      else
        return nil
      end
    end
    
    # No sequences with M = P, proceed with CRT
    diffs = other_sequences.map { |c, m| m - p }
    moduli = diffs.map(&:abs)
    constants = other_sequences.map { |c, m| c }
   
    # This check probably is not needed now
    return nil if moduli.any?(&:zero?)
    
    i_mod_lcm = solve_crt(constants, moduli)
    return nil unless i_mod_lcm
    
    i_solution, lcm = i_mod_lcm
    
    # Find I with smallest absolute value
    min_abs_i = nil
    min_abs_value = Float::INFINITY
    
    (-200..200).each do |shift|
      test_i = i_solution + shift * lcm
      if verify_solution(sequences, test_i, p)
        if test_i.abs < min_abs_value
          min_abs_i = test_i
          min_abs_value = test_i.abs
        end
      end
    end
    
    return [min_abs_i, p] if min_abs_i
    nil
  end

  def solve_crt(remainders, moduli)
    return nil if remainders.length != moduli.length
    return [remainders[0], moduli[0]] if remainders.length == 1
    
    x = remainders[0]
    m = moduli[0]
    
    (1...remainders.length).each do |i|
      a = remainders[i]
      n = moduli[i]
      
      diff = a - x
      g = m.gcd(n)
      
      return nil if diff % g != 0
      
      m_reduced = m / g
      n_reduced = n / g
      diff_reduced = diff / g
      
      inv = mod_inverse(m_reduced, n_reduced)
      return nil unless inv
      
      k = (inv * diff_reduced) % n_reduced
      x = x + k * m
      m = m.lcm(n)
      x = x % m
    end
    
    [x, m]
  end

  def mod_inverse(a, m)
    return nil if a < 0 || m <= 0
    
    g, x, _ = extended_gcd(a, m)
    return nil if g != 1
    
    (x % m + m) % m
  end

  def extended_gcd(a, b)
    return [b, 0, 1] if a == 0
    
    gcd, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b / a) * x1
    y = x1
    
    [gcd, x, y]
  end

  def verify_solution(sequences, i, p)
    sequences.all? do |c, m|
      if m == p
        # Special case: when M = P, we need I = C
        i == c
      else
        denominator = m - p
        numerator = i - c
        return false if numerator % denominator != 0
        
        n = numerator / denominator
        n >= 0
      end
    end
  end

  # Vibe coded part2
  def part2
    parse
    debug { "STONES: #{@stones.length}\n" }
    solution = []
    [:x, :y, :z].each do |dim|
      sequences = @stones.map do |stone|
        [stone[0].send(dim), stone[1].send(dim)]
      end
      result = find_sequence(sequences)
      if result
        solution << result
      else
        puts "Could not find solution for dimension #{dim.inspect}"
      end
    end
    puts "SOLUTION: #{solution.inspect}"
    solution.map{|a| a[0]}.sum
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
