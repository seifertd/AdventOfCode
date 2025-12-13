require 'set'

class Solution
  def parse
    @graph = Hash.new{|h,k| h[k] = Set.new}
    input do |line|
      node, connections = line.split(": ")
      connections.split(" ").each do |c|
        @graph[node] << c
      end
    end
  end
  def all_paths(source, dest, require_nodes = nil, prune_if_no_match = nil)
    curr_path = []
    paths = [0]
    visited = Hash.new{|h,k| h[k] = false}
    find_paths(source, dest, curr_path, visited, paths, require_nodes, prune_if_no_match)
    paths
  end
  def find_paths(curr, dest, curr_path, visited, paths, require_nodes, prune_if_no_match)
    visited[curr] = true
    curr_path << curr
    prune_path = false
    if require_nodes
      if require_nodes.keys.any?{|rn| rn == curr}
        require_nodes[curr] = true
      end
      if require_nodes.any?{|rn, rn_visited| rn != curr && !rn_visited && @levels[rn] <= @levels[curr] }
        # we need to prune this path, it won't meet the requirements
        prune_path = true
      end
    end
    if prune_if_no_match
      prune_path = !prune_if_no_match.include?(curr)
    end
    if dest == curr
      paths[0] += 1
      if paths[0] % 10000 == 0
        debug { "\rFound #{paths[0]} paths so far ..." }
      end
    elsif !prune_path
      @graph[curr].each do |n|
        if !visited[n]
          find_paths(n, dest, curr_path, visited, paths, require_nodes, prune_if_no_match)
        end
      end
    end
    curr_path.pop
    visited[curr] = false
    if require_nodes
      if require_nodes.keys.any?{|rn| rn == curr}
        require_nodes[curr] = false
      end
    end
  end
  def part1
    parse
    all_paths('you', 'out')[0]
  end
  def find_node_levels(source, dest)
    @levels = Hash.new{|h,k| h[k] = -1 }
    @levels[source] = 0
    children = @graph[source]
    level = 1
    while children.size > 0
      debug { "Level: #{level}: children: #{children.count}\n" }
      children.each { |c| @levels[c] = level }
      level += 1
      children = children.inject(Set.new) { |nc, node| nc.merge(@graph[node]) }
    end
  end
  def find_parents(node)
    @graph.keys.inject(Set.new) do |parents, n|
      if @graph[n].include?(node)
        parents << n
      end
      parents
    end
  end
  def ancestors_to(dest, source)
    visited = Hash.new{|h,k| h[k] = false }
    parents = find_parents(source)
    ancestors = Set.new
    while parents.size > 0
      # filter out any at the wrong level
      parents = parents.select {|p| @levels[p] > @levels[dest]}
      break if parents.size == 0
      ancestors.merge parents
      new_parents = Set.new
      parents.each do |p|
        new_parents.merge(find_parents(p))
      end
      parents = new_parents
    end
    ancestors << dest
    ancestors
  end
  def part2
    parse
    find_node_levels('svr', 'out')
    debug { "Levels: #{@levels.count}\n" }
    svr_to_fft = all_paths('svr', 'fft', {'fft' => false, 'dac' => false})[0]
    debug { "svr->fft: #{svr_to_fft}\n" }

    # TODO COUNT ALL PATHS Between fft and dac
    dac_to_fft_visited = ancestors_to('fft', 'dac')
    fft_to_dac = all_paths('fft', 'dac', nil, dac_to_fft_visited)[0]
    debug { "fft->dac: #{fft_to_dac}\n" }

    dac_to_out = all_paths('dac', 'out', {'dac' => false})[0]
    debug { "dac->out: #{dac_to_out}\n" }

    svr_to_fft * fft_to_dac * dac_to_out
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
