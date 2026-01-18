require 'set'

class Solution
  def parse
    @nodes = SortedSet.new
    @edges = []
    re = /([^ ]+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\.$/
    input do |line|
      md = line.match(re)
      raise "Regex needs work" if md.nil?
      source, gainlose, happiness, target = md.captures
      happiness = happiness.to_i
      mult = gainlose == 'gain' ? 1 : -1
      debug { " -> Source:#{source} +/-:#{mult} amt:#{happiness} target:#{target}\n" }
      @nodes << source << target
      e = @edges.find do |e|
        e[0] == source && e[1] == target ||
        e[1] == source && e[0] == target
      end
      if e.nil?
       e = [source, target, 0]
       @edges << e
      end
      e[2] += (mult * happiness)
    end
  end
  def most_happy
    @max_happy = 0
    source = @nodes.first
    visited = Set.new([source])
    most_happy_dfs(source, source, visited, 0)
    @max_happy
  end
  def most_happy_dfs(source, node, visited, len)
    if visited.size == @nodes.size
      # count the last edge.
      last_edge = @edges.find do |e|
        e[0] == source && e[1] == node ||
        e[0] == node && e[1] == source
      end
      raise "Couldn't find last edge between #{source} and #{node}" if last_edge.nil?
      len += last_edge[2]
      @max_happy = [@max_happy, len].max
    end
    next_guests = @edges.find_all do |e|
      e[0] == node || e[1] == node
    end
    next_guests.sort_by{|e| -e[2]}.each do |e|
      next_guest = e[0] == node ? e[1] : e[0]
      if !visited.include?(next_guest)
        visited << next_guest
        most_happy_dfs(source, next_guest, visited, len + e[2])
        visited.delete(next_guest)
      end
    end
  end
  def part1
    parse
    debug { "Nodes: #{@nodes}\n" }
    debug { "Edges: #{@edges}\n" }
    most_happy
  end
  def part2
    parse
    @nodes.each do |node|
      @edges << [node, 'Me', 0]
    end
    @nodes << 'Me'
    most_happy
  end
  def input
    if block_given?
      ARGF.each_line do |line|
        line.chomp!
        yield(line)
      end
    else
      return to_enum(:input)
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
