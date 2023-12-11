require_relative '../common/cycle.rb'

Map = Struct.new(:nodes, :instructions) do
  def reset
    self.instructions.reset
  end
end

def parse_map
  map = Map.new
  map.nodes = {}
  ARGF.readlines.each do |line|
    line.chomp!
    next if line == ""
    if map.instructions.nil?
      map.instructions = Cycle.new line.split(//)
    else
      key, pair = line.split(" = ")
      pair = pair.sub('(', '').sub(')', '').split(", ")
      map.nodes[key] = pair
    end
  end
  map
end

def part1(map, current = 'AAA', finish = 'ZZZ')
  steps = 0
  #puts "START: #{current}"
  while (finish == 'part2' && !current.end_with?('Z') || (finish != 'part2' && current != finish))
    inst = map.instructions.next
    current = map.nodes[current][inst == 'L' ? 0 : 1]
    #puts "    NEXT: #{current}"
    steps += 1
  end
  #puts "END: #{current}"
  steps
end

def part2(map)
  current = map.nodes.keys.find_all{|n| n.end_with?('A')}
  #puts "STARTING NODES: #{current.inspect}"
  cycle_lengths = current.map do |node|
    map.reset
    part1(map, node, 'part2')
  end
  #puts "CYCLE LENGTHS: #{cycle_lengths.inspect}"
  cycle_lengths.inject(1) { |lcm, len| lcm.lcm(len) }
end

map = parse_map
puts "Part 1: #{part1(map)}"
puts "Part 2: #{part2(map)}"
