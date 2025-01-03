class Solution
  def parse_network
    program = []
    registers = {}
    input do |line|
      if line.include?(": ")
        node, val = line.split(": ")
        registers[node] = val.to_i
      end
      if line.include?(" -> ")
        eq, output = line.split(" -> ")
        a1, op, a2 = eq.split(" ")
        program << [a1, op, a2, output]
        registers[output] = nil
      end
    end
    [program, registers]
  end
  def execute(program, registers, swaps = nil)
    program = Marshal.load(Marshal.dump(program))
    registers = Marshal.load(Marshal.dump(registers))
    if !swaps.nil?
      t = program[swaps[0]].last
      program[swaps[0]][3] = program[swaps[1]].last
      program[swaps[1]][3] = t
      t = program[swaps[2]].last
      program[swaps[2]][3] = program[swaps[3]].last
      program[swaps[3]][3] = t
      if swaps.size > 4
        t = program[swaps[4]].last
        program[swaps[4]][3] = program[swaps[5]].last
        program[swaps[5]][3] = t
      end
      if swaps.size > 6
        t = program[swaps[6]].last
        program[swaps[6]][3] = program[swaps[7]].last
        program[swaps[7]][3] = t
      end
    end
    while program.size > 0
      line = program.shift
      a1, op, a2, output = line
      if registers[a1].nil? || registers[a2].nil?
        program << line
        next
      end
      case op
      when 'AND'
        registers[output] = registers[a1] & registers[a2]
      when 'XOR'
        registers[output] = registers[a1] ^ registers[a2]
      when 'OR'
        registers[output] = registers[a1] | registers[a2]
      end
    end
    registers
  end
  def part1
    program, registers = parse_network
    debug { "PROGRAM: #{program.count} instructions\n" }
    registers = execute(program, registers)
    result = 0
    debug { "REGISTERS: #{registers.count}: #{registers.inspect}\n" }
    registers.keys.find_all{|k| k.start_with?('z')}.sort.reverse.each do |reg|
      result = (result << 1) | registers[reg]
      debug {"REG: #{reg} VAL: #{registers[reg]} RESULT: #{result}\n"}
    end
    result
  end
  def check(registers)
    x = registers.keys.find_all{|k| k.start_with?('x')}.sort.reverse.inject(0) do |sum, reg|
      sum = (sum << 1) | registers[reg]
    end
    y = registers.keys.find_all{|k| k.start_with?('y')}.sort.reverse.inject(0) do |sum, reg|
      sum = (sum << 1) | registers[reg]
    end
    z = registers.keys.find_all{|k| k.start_with?('z')}.sort.reverse.inject(0) do |sum, reg|
      sum = (sum << 1) | registers[reg]
    end
    #debug { "x:#{x}(#{x.to_s(2)}) + y:#{y}(#{y.to_s(2)}) = z:#{z}(#{z.to_s(2)})(sum:#{x & y}=#{(x & y).to_s(2)})\n"}
    (x & y) == z
  end
  def word(program, combo)
    combo.map{|c| program[c][3]}.sort.join(',')
  end
  def part2
    program, registers = parse_network
    debug { "PROGRAM: #{program.size} instructions\n" }
    new_regs = execute(program, registers)
    debug { "REGISTERS: #{new_regs.count}:\n#{new_regs.map{|k,v| "#{k}: #{v}"}.join("\n")}\n" }
    debug { "EXECUTED, WORKS: #{check(new_regs).inspect}\n"}
    pairs = program.size.times.to_a.combination(2).to_a
    debug { "NUM PAIRS: #{pairs.size}\n"}
    debug { "NUM COMBOS: #{pairs.combination(2).size}\n"}
    pairs.combination(2).each do |combo|
      pair1 = combo[0]
      pair2 = combo[1]
      #pair3 = combo[2]
      #pair4 = combo[3]
      next if pair2.include?(pair1[0]) || pair2.include?(pair1[1])
      #next if pair3.include?(pair1[0]) || pair3.include?(pair1[1])
      #next if pair4.include?(pair1[0]) || pair4.include?(pair1[1])
      #next if pair3.include?(pair2[0]) || pair4.include?(pair2[1])
      #next if pair4.include?(pair2[0]) || pair4.include?(pair2[1])
      #next if pair4.include?(pair3[0]) || pair4.include?(pair3[1])
      combo = [pair1, pair2].flatten
      #combo = [pair1, pair2, pair3, pair4].flatten
      new_regs = execute(program, registers, combo)
      if check(new_regs)
        puts "COMBO: #{combo.inspect} #{word(program,combo)}"
      end
    end
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
