require 'set'

class Solution
  def read_graph
    graph = Hash.new {|h,k| h[k] = Set.new}
    input do |line|
      if line == "st-sl"
        debug { "READ st-sl\n"}
      end
      n1, n2 = line.split("-")
      graph[n1] << n2
      graph[n2] << n1
    end
    graph
  end
  def part1
    graph = read_graph
    debug { "READ #{graph.size} nodes\n"}
    nets = Set.new
    graph.keys.each do |n1|
      connected = graph[n1]
      connected.each do |n2|
        connected.each do |n3|
          next if n3 == n2
          if graph[n3].include?(n2)
            nets << [n1,n2,n3].sort
          end
        end
      end
    end
    nets.find_all do |net|
      debug { "#{net.join(",")}\n" }
      net.any?{|n| n.start_with?('t')}
    end.count
  end
  def bron_kerbosch(graph, r = Set.new, p = nil, x = Set.new, &block)
    if p.nil?
      p = Set.new graph.keys
    end
    if p.empty? && x.empty?
      block.call(r)
    else
      u = (p | x).first
      (p - graph[u]).each do |v|
        bron_kerbosch(graph, r | [v], p & graph[v], x & graph[v], &block)
        p.delete(v)
        x.add(v)
      end
    end
  end
  def part2
    graph = read_graph
    debug { "READ GRAPH: #{graph.size} NODES\n"}
    cliques = []
    bron_kerbosch(graph) do |clique|
      debug { "FOUND A CLIQUE: #{clique.inspect} SIZE: #{clique.size}\n"}
      cliques << clique
    end
    max_size = cliques.map(&:size).max
    debug { "MAX CLIQUE SIZE: #{max_size}\n"}
    max_clique = cliques.find{|c| c.size == max_size }
    max_clique.to_a.sort.join(',')
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
