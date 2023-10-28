class Comp
  attr_accessor :program, :acc, :counter
  def initialize
    @program = []
  end
  def list
    @program.each.with_index do |statement, idx|
      puts "#{idx}: #{statement.inspect}"
    end
  end
  def compile_line(line)
    op, arg = line.split(" ")
    @program << [op, arg.to_i]
  end
  def run(debug = false)
    visited = []
    @acc = 0
    @counter = 0
    while true
      if @counter >= @program.length
        return true
      end
      if visited[@counter]
        puts "LOOP: #{@counter}" if debug
        return false
      end
      visited[@counter] = true
      command = @program[@counter]
      puts "#{@counter} (a=#{@acc}): #{command.inspect}" if debug
      case command[0]
      when "acc"
        @acc += command[1]
        @counter += 1
      when "jmp"
        @counter += command[1]
        if @counter < 0 || @counter > @program.length
          raise "Program counter #{@counter} is out of bounds, program len = #{@program.length}"
        end
      else
        @counter += 1
      end
    end
  end
end

c = Comp.new
ARGF.each do |line|
  c.compile_line line
end

if ENV['PART'] == '1'
  ok = c.run
  puts "OK? #{ok} acc = #{c.acc} on instruction #{c.counter}"
elsif ENV['PART'] == '2'
  ['nop', 'jmp'].each do |changing|
    puts "CHANGING: #{changing}"
    changeline = 0
    lastchange = -1
    nextop = false
    while !c.run(false) && !nextop
      statement = c.program[changeline]
      while statement.first != changing && !nextop
        changeline += 1
        if changeline >= c.program.length
          nextop = true
          break
        end
        statement = c.program[changeline]
      end
      if !nextop
        puts "CHANGING #{changeline}: #{statement.inspect}"
        c.program[changeline][0] = statement.first == 'nop' ? 'jmp' : 'nop'
        if lastchange >= 0
          # change back the last change if there is one
          c.program[lastchange][0] = c.program[lastchange][0] == 'nop' ? 'jmp' : 'nop'
        end
        lastchange = changeline
      else
        if lastchange >= 0
          # change back the last change if there is one
          c.program[lastchange][0] = c.program[lastchange][0] == 'nop' ? 'jmp' : 'nop'
        end
      end
    end
    if !nextop
      puts "Changed line #{changeline} from #{changing}, acc: #{c.acc}"
      #c.list
      break
    end
  end
           
end
