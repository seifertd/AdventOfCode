require 'set'

class Solution
  LOOP = 1
  OK = 0
  BAD_OUTPUT = 2
  OPS = {
    0 => :adv,
    1 => :bxl,
    2 => :bst,
    3 => :jnz,
    4 => :bxc,
    5 => :out,
    6 => :bdv,
    7 => :cdv
  }
  attr_accessor :a, :b, :c, :ip, :program, :output
  def adv(op)
    num = self.a
    den = 2 ** combo_op(op)
    self.a = (num / den)
    #debug "ADV: #{num}/#{den} = #{self.a}\n"
    self.ip += 2
  end
  def bxl(op)
    #debug "BXL: #{self.b} ^ #{op} = "
    self.b = (self.b ^ op)
    #debug "#{self.b}\n"
    self.ip += 2
  end
  def bst(op)
    self.b = combo_op(op) % 8
    self.ip += 2
  end
  def jnz(op)
    if self.a == 0
      self.ip += 2
    else
      self.ip = op
    end
  end
  def bxc(op)
    #debug "BXC: #{self.b} ^ #{self.c} = "
    self.b = (self.b ^ self.c)
    #debug "#{self.b}\n"
    self.ip += 2
  end
  def out(op)
    self.output << (combo_op(op) % 8)
    self.ip += 2
  end
  def bdv(op)
    num = self.a
    den = 2 ** combo_op(op)
    self.b = num / den
    self.ip += 2
  end
  def cdv(op)
    num = self.a
    den = 2 ** combo_op(op)
    self.c = num / den
    self.ip += 2
  end
  def combo_op(v)
    case v
    when 0,1,2,3
      v
    when 4
      self.a
    when 5
      self.b
    when 6
      self.c
    when 7
      raise "Invalid combo operand: #{v.inspect}"
    else
      raise "Unknown combo operand: #{v.inspect}"
    end
  end
  def parse_program
    input do |line|
      if line.start_with?("Register A: ")
        self.a = line.split(": ").last.to_i
      end
      if line.start_with?("Register B: ")
        self.b = line.split(": ").last.to_i
      end
      if line.start_with?("Register C: ")
        self.c = line.split(": ").last.to_i
      end
      if line.start_with?("Program: ")
        self.program = line.split(": ").last.split(',').map(&:to_i)
      end
    end
    self.ip = 0
    self.output = []
  end
  def run
    while self.ip < self.program.length - 1
      #debug "   > OPCODE: #{self.program[self.ip]} OP: #{OPS[self.program[self.ip]]} OPERAND: #{self.program[self.ip+1]} IP: #{self.ip}\n"
      currstate = [self.a, self.b, self.c]
      self.send(OPS[self.program[self.ip]], self.program[self.ip + 1])
      #debug "   < A: #{self.a} B: #{self.b} C: #{self.c}\n"
    end
    #debug "STOP PROGRAM: REGISTERS: A: #{self.a} B: #{self.b} C: #{self.c} ip: #{self.ip}\n"
    #debug "OUTPUT: #{self.output.inspect}\n"
  end
  def reset(registers)
    self.a = registers[0]
    self.b = registers[1]
    self.c = registers[2]
    self.ip = 0
    self.output = []
  end
  def part1
    parse_program
    run
    debug "OUTPUT:[#{self.output.join(',')}]\n"
    self.output.join(',')
  end
  def part2
    parse_program
    oregs = [self.a, self.b, self.c]
    ans = -1
    new_a = 0
    oa = 0
    debug "PROGRAM: #{self.program.inspect}\n"
    p_idx = 1
    loop do
      reset([new_a, oregs[1], oregs[2]])
      run
      if self.output == self.program[-p_idx,p_idx]
        if p_idx == self.program.length
          debug "p_idx: #{p_idx} oa: #{oa} new_a: #{new_a} out: #{self.output.inspect} prog #{self.program.inspect}\n"
          ans = oa
          break
        end
        debug "p_idx: #{p_idx} oa: #{oa} a: #{a} out: #{self.output.inspect} prog #{self.program.inspect}\n"
        p_idx += 1
        oa *= 8
        new_a = oa
      else
        oa += 1
        new_a = oa
      end
    end
    ans
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
