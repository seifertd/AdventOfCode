Machine = Struct.new(:target, :size, :buttons, :joltage) do
  def initialize
    self.buttons = []
  end
  def to_s
    if self.buttons.first.is_a? Array
      "Machine: 0b#{self.target.to_s(2)} Buttons: #{self.buttons.size} #{self.buttons.map(&:inspect).join(" ")} Joltage: #{self.joltage.join(',')}"
    else
      "Machine: 0b#{self.target.to_s(2)} Buttons: #{self.buttons.size} #{self.buttons.map{|b| b.to_s(2)}.join(",")} Joltage: #{self.joltage.join(',')}\n"
    end
  end
  def inspect
    to_s
  end
end

class Solution
  def parse(part1 = true)
    @machines = []
    input do |line|
      m = Machine.new
      pieces = line.split(' ')
      m_spec = pieces.shift
      m.size = m_spec.size - 2
      m.target = eval("0b" + m_spec[1..-2].reverse.gsub('.', '0').gsub('#','1'))
      while b_spec = pieces.shift
        if b_spec.start_with?('(')
          if part1
            num = b_spec[1..-2].split(',').inject(0) { |sum, shift| sum |= (1 << shift.to_i) }
            m.buttons << num
          else
            m.buttons << b_spec[1..-2].split(',').map(&:to_i)
          end
        elsif b_spec.start_with?('{')
          m.joltage = b_spec[1..-2].split(',').map(&:to_i)
        end
      end
      @machines << m
    end
    debug { "Machines: #{@machines.inspect}\n" }
  end
  def min_presses_part1(m)
    buttons = 1
    while true
      m.buttons.combination(buttons).each do |presses|
        state = 0
        #debug { "Machine #{m} pressing #{presses.inspect}\n" }
        presses.each do |press|
          state ^= press
        end
        #debug { "Machine #{m} final state: #{state}\n" }
        if state == m.target
          debug { "Machine #{m} reached target in #{buttons} presses #{presses.inspect}\n" }
          return buttons
        end
      end
      buttons += 1
    end
  end
  def part1
    parse
    @machines.map{ |m| min_presses_part1(m) }.inject(&:+)
  end
  def min_presses_part2(m)
    joltage_accumulator = Array.new(m.joltage.size) { 0 }
    targets = m.joltage.each.with_index.sort
    debug { "Machine: #{m}\n" }
    debug { "Joltage targets: #{targets.inspect}\n" }
    search(m, targets, [], joltage_accumulator, 0, 1_000_000)
  end
  def search(m, targets, prev_j_idxs, joltage_accumulator, presses, min_presses)
    if targets.size == 0
      return -1
    end
    target, j_idx = targets[0]
    presses_needed = m.joltage[j_idx] - joltage_accumulator[j_idx]
    if presses + presses_needed >= min_presses
      # prune this branch
      return -1
    end
    buttons = m.buttons.find_all{|b| b.include?(j_idx) && prev_j_idxs.none?{|pji| b.include?(pji)} }
    #debug { " Target: #{target}, j_idx: #{j_idx} p_j_idx: #{prev_j_idxs} buttons: #{buttons.inspect} j: #{joltage_accumulator.inspect} target: #{m.joltage.inspect}\n" }

    #debug { " Possible buttons: #{buttons.inspect}\n" }
    previous_joltage_accumulator = joltage_accumulator.map{|j| j}
    #debug { " Presses needed: #{presses_needed}\n" }
    answers = []
    button_combos = buttons.repeated_combination(presses_needed)
    #debug { "Iterating over #{button_combos.size} combos\n" }
    button_combos.each do |button_combo|
      #debug { " button_combo: #{button_co}bo.size} prev: #{previous_joltage_accumulator} current joltages: #{joltage_accumulator} presses: #{presses}\n" }
      button_combo.tally.each do |button, count|
        button.each do |b_j_idx|
          joltage_accumulator[b_j_idx] += count
        end
      end
      presses += button_combo.size
      #debug { "Accumulator: #{joltage_accumulator.inspect} Target Joltage: #{m.joltage.inspect}\n" }
      if joltage_accumulator == m.joltage
        debug { "Found possible answer: #{presses}\n" }
        min_presses = [min_presses, presses].min
        answers << presses
        presses -= button_combo.size
        joltage_accumulator = previous_joltage_accumulator.map{|j| j}
        next
      end
      if joltage_accumulator.each.with_index.any? {|j2,i2| j2 > m.joltage[i2] }
        #debug { "Joltages exceeded, stopping: #{joltage_accumulator.inspect}\n" }
        presses -= button_combo.size
        joltage_accumulator = previous_joltage_accumulator.map{|j| j}
      else
        #debug { "Recursing to next target\n" }
        # Always look for the one with fewest presses needed 
        new_p_j_idxs = prev_j_idxs + [j_idx]
        new_targets = targets[1..-1].sort_by do |(target, j_idx)|
          m.joltage[j_idx] - joltage_accumulator[j_idx]
        end
        result = search(m, new_targets, new_p_j_idxs, joltage_accumulator, presses, min_presses)
        if result == -1
          joltage_accumulator = previous_joltage_accumulator.map{|j| j}
          presses -= button_combo.size
        else
          min_presses = [min_presses, result].min
          answers << result
          joltage_accumulator = previous_joltage_accumulator.map{|j| j}
          presses -= button_combo.size
        end
      end
    end
    #debug { "Found possible answers: #{answers.inspect}\n" }
    return answers.min || -1
  end
  def min_presses_part2_z3(m)
    num_constants = m.buttons.size
    coefficients = (0...m.joltage.size).map do |idx|
      m.buttons.each_with_index.inject([]) do |cs, (b, bidx)| 
        if b.include?(idx)
          cs << "n#{bidx}"
        end
        cs
      end.join(" ")
    end
    smt2_file = <<-END
; machine: #{m.to_s.strip}
(set-logic QF_LIA) ; Quantifier-Free Linear Integer Arithmetic (or QF_LRA for Reals)
#{(0...m.buttons.size).map{|i| "(declare-const n#{i} Int)" }.join("\n")}
#{(0...m.buttons.size).map{|i| "(assert (>= n#{i} 0))" }.join("\n")}
(minimize (+ #{(0...m.buttons.size).map{|i| "n#{i}" }.join(" ")}))
#{coefficients.each_with_index.map{|co,i| "(assert (= (+ #{co}) #{m.joltage[i]}))"}.join("\n")}
(check-sat)
(get-model)
    END
    sum = 0
    IO.popen("z3 -in", "r+") do |pipe|
      pipe.write smt2_file
      pipe.close_write
      pipe.each do |line|
        if line.start_with?("(error")
          raise "ERROR: #{line}"
        end
        if line =~ /^\s+(\d+)\)/
          sum += $1.to_i
        end
      end
      pipe.close
    end
    sum
  end
  def part2
    parse(false)
    runs = 0
    @machines.map.with_index do |m, m_idx|
      if ENV['SKIP_TO'] && ENV['SKIP_TO'].to_i > m_idx
        next
      end
      #presses = min_presses_part2(m)
      presses = min_presses_part2_z3(m)
      puts "#{m_idx+1} of #{@machines.size}: PRESSES FOR MACHINE: #{presses}"
      runs += 1
      if ENV['RUNS'] && ENV['RUNS'].to_i >= runs
        next
      end
      presses
    end.inject(&:+)
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
