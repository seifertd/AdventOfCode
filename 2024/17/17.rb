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
  def run(require_self_output = false)
    debug "START PROGRAM: #{self.program.inspect}\n"
    debug "REGISTERS: A: #{self.a} B: #{self.b} C: #{self.c}\n"
    looping = false
    runstate = Hash.new {|h,k| h[k] = Set.new}
    while self.ip < self.program.length - 1 && !looping
      debug "   > OPCODE: #{self.program[self.ip]} OP: #{OPS[self.program[self.ip]]} OPERAND: #{self.program[self.ip+1]} IP: #{self.ip}\n"
      currstate = [self.a, self.b, self.c]
      if require_self_output
        output.each.with_index do |o, oidx|
          if o != self.program[oidx]
            return BAD_OUTPUT
          end
        end
      end
      if runstate[self.ip].include?(currstate)
        debug "LOOP DETECTED: ip:#{self.ip} registers: #{currstate.inspect}\n"
        looping = true
        break
      else
        runstate[self.ip] << currstate 
      end
      self.send(OPS[self.program[self.ip]], self.program[self.ip + 1])
      debug "   < A: #{self.a} B: #{self.b} C: #{self.c}\n"
    end
    debug "STOP PROGRAM: REGISTERS: A: #{self.a} B: #{self.b} C: #{self.c} looping: #{looping} ip: #{self.ip}\n"
    debug "OUTPUT: #{self.output.inspect}\n"
    looping ? LOOP : OK
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
  def part2_sample2
    oa = 1
    a = 1
    b = 0
    c = 0
    prog = [0,3,5,4,3,0]
    out = []
    ans = -1
    while true
      a = a / (2 ** 3) # 0,3 adv(3)
      out << (a % 8)   # 5,4 out(4)
      if out == prog
        # we have the answer
        ans = oa
        break
      end
      if out != prog[0,out.length] || a == 0
        # next a
        out = []
        oa = oa + 1
        a = oa
        b = 0
        c = 0
      end
    end
    debug "OUT: #{out.inspect} PROG: #{prog.inspect}\n"
    ans
  end
  def part2_input
    oa = 1 
    a = 1
    b = 0
    c = 0
    ip = 0
    prog = [2,4,1,1,7,5,0,3,1,4,4,4,5,5,3,0]
    out = []
    ans = -1
    loop do
      b = a % 8  #bst(4) 2,4
      b = b ^ 1  #bxl(1) 1,1
      c = a / (2 ** b) #cdv(5) 7,5
      a = a / (2 ** 3) #adv(3) 0,3
      b = b ^ 4   # bxl(4) 1,4
      b = b ^ c   # bxc(4) 4,4
      out << (b % 8) # 5,5
      if out == prog
        # we have the answer
        ans = oa
        break
      end
      if out != prog[0,out.length] || a == 0
        debug "ITER: #{oa} A:#{a} B:#{b} C:#{c} OUT: #{out.inspect}\n" if oa % 1_000_000 == 3
        # next a
        out = []
        oa = oa + 1
        a = oa
        b = 0
        c = 0
      end
    end
    ans
  end
  def part2
    part2_input
  end
  def part2_old
    parse_program
    oregs = [self.a, self.b, self.c]
    ans = -1
    new_a = 1
    debug "PROGRAM: #{self.program.inspect}\n"
    loop do
      reset([new_a, oregs[1], oregs[2]])
      status = run(true)
      if status == LOOP
        debug "Register value #{new_a} produced infinite loop"
      elsif status == BAD_OUTPUT
        #debug "Program not producing self for #{new_a}\n"
      else
        if self.output == self.program
          ans = new_a
          break
        end
      end
      if new_a % 10000 == 0
        debug "A: #{new_a} OUTPUT: #{self.output.inspect}\n"
      end
      new_a += 1
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
