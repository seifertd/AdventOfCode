class Solution
  def part1
    instructions = ARGF.read
    #mulre = /(?:[^a-z]|^)(mul\(\d+,\d+\))/
    mulre = /(mul\(\d+,\d+\))/
    result = 0
    while m = instructions.match(mulre)
      multiplication = m[1].gsub('mul(','').gsub(')', '').split(',').map(&:to_i).inject(&:*)
      result += multiplication
      instructions = instructions[m.end(1)..-1]
    end
    result
  end
  def part2
    enabled = true
    mulre = /mul\(\d+,\d+\)/
    dore = /do\(\)/
    dontre = /don't\(\)/
    instructions = ARGF.read
    result = 0
    while m = instructions.match(mulre)
      if enabled
        dontm = instructions.match(dontre)
        debug "enabled? #{enabled}: FOUND MULT: #{m[0]}#{m.begin(0)} CLOSEST DONT: #{dontm.inspect}#{(dontm ? dontm.begin(0) : '')}\n"
        if !dontm.nil? && dontm.begin(0) < m.begin(0)
          debug "DISABLING\n"
          enabled = false
          instructions = instructions[m.end(0)..-1]
          next
        end
      else
        dom = instructions.match(dore)
        debug "enabled? #{enabled}: FOUND MULT: #{m[0]}#{m.begin(0)} CLOSEST DO: #{dom.inspect}#{(dom ? dom.begin(0) : '')}\n"
        if !dom.nil? && dom.begin(0) < m.begin(0)
          debug "ENABLING\n"
          enabled = true
          instructions = instructions[dom.end(0)..-1]
          next
        else
          instructions = instructions[m.end(0)..-1]
          next
        end
      end
      debug "COUNTING MULT\n"
      multiplication = m[0].gsub('mul(','').gsub(')', '').split(',').map(&:to_i).inject(&:*)
      result += multiplication
      instructions = instructions[m.end(0)..-1]
    end
    result
  end
  def debug(msg)
    if ENV['DEBUG']
      print(msg)
    end
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
end

if __FILE__ == $0
  solution = Solution.new
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
