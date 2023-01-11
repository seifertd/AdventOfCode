Monkey = Struct.new(:inspected, :items, :op, :arg, :test, :tact, :fact)

class Frac
  attr_reader :n, :d
  def initialize(n, d)
    @n = n
    @d = d
  end
  def *(m)
    if m.is_a?(Frac)
      if ((@n * m.n) % (@d * m.d)) == 0
        ( @n * m.n ) / ( @d * m.d)
      else
        Frac.new(@n * m, @d * m.d)
      end
    else
      if ((@n * m) % d) == 0
        @n * m / @d
      else
        Frac.new(@n * m / @d)
      end
    end
  end
  def to_s
    "#{@n}/#{@d}"
  end
end

monkies = []
common_mult = 1
ARGF.each_line do |line|
  line.chomp!
  if line.start_with?("Monkey")
    monkies << Monkey.new
    monkies.last.inspected = 0
  end
  if line.start_with?("  Starting")
    items = line.split(": ").last.split(", ").map(&:to_i)
    monkies.last.items = items
  end
  if line.start_with?("    If true:")
    if md = line.match(/(\d+)/)
      monkies.last.tact = md[1].to_i
    else
      raise "Could not parse true action"
    end
  end
  if line.start_with?("    If false:")
    if md = line.match(/(\d+)/)
      monkies.last.fact = md[1].to_i
    else
      raise "Could not parse false action"
    end
  end
  if line.start_with?("  Test:")
    if md = line.match(/(\d+)/)
      monkies.last.test = md[1].to_i
      common_mult *= md[1].to_i
    else
      raise "Could not parse true action"
    end
  end
  if line.start_with?("  Operation")
    eq = line.split("new =").last
    if md = eq.match(/old (.) (.+)$/)
      monkies.last.op = md[1]
      if md[2] == 'old'
        monkies.last.arg = :old
      else
        monkies.last.arg = md[2].to_i
      end
    else
      raise "Could not parse operation"
    end
  end
end

reduce = ->(monkey, num) {
  arg = monkey.arg == :old ? num : monkey.arg
  if monkey.op == '*'
    tnum = num * arg
  else
    tnum = num + arg
  end
  rem = tnum % monkey.test
  if monkey.op == '*'
    Frac.new(rem, arg)
  else
    rem - arg <= 0 ? rem + arg : rem - arg
  end
}
require 'ruby-progressbar'
N = 10000
pb = ProgressBar.create(:total => N, :title => "Rounds")
N.times do
  monkies.each_with_index do |monkey, idx|
    while item = monkey.items.shift
      monkey.inspected += 1
      worry = item
      #puts "Monkey #{idx}: Inspect #{item}"
      arg = monkey.arg == :old ? worry : monkey.arg
      if monkey.op == '*'
        worry *= arg
      else
        worry += arg
      end
      #puts "  op complete #{monkey.op} #{monkey.arg.inspect}, worry now #{worry}"
      worry = worry % common_mult
      #puts "  worry now #{worry}"
      if (worry % monkey.test) == 0
        #puts "  test passed #{worry} to #{monkey.tact}"
        #worry = reduce.call(monkies[monkey.tact], worry)
        #puts "  AFTER REDUCTION: test failed #{worry} to #{monkey.tact}"
        monkies[monkey.tact].items.push(worry)
      else
        #puts "  test failed #{worry} to #{monkey.fact}"
        #worry = reduce.call(monkies[monkey.fact], worry)
        #puts "  AFTER REDUCTION: test failed #{worry} to #{monkey.fact}"
        monkies[monkey.fact].items.push(worry)
      end
    end
  end
  pb.increment
end

monkies.each do |m|
  puts m.items.inspect
end
inspections = monkies.map(&:inspected).sort.reverse

puts "Inspections: #{inspections.inspect}"
puts "Part 1: #{inspections[0] * inspections[1]}"
