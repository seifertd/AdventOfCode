require '../../common/point'
class Point
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.x >= cols || p.y >= rows }
  end
end

$pathnum = 1

class Solution
  def parse
    @grid = []
    @start = nil
    @finish = nil
    @rows = @cols = nil
    row = 0
    input do |line|
      @grid << line.split(//)
      @cols ||= @grid.last.size
      if row == 0
        @start = Point.new(@grid.last.index('.'), row)
      end
      row += 1
    end
    @rows = row
    @finish = Point.new(@grid.last.index('.'), row - 1)
  end
  def print_path(path)
    grid = Marshal.load(Marshal.dump(@grid))
    path.each do |p|
      if !['<', '>', '^', 'v'].include?(grid[p.y][p.x])
        if grid[p.y][p.x] == '#'
          grid[p.y][p.x] = "\033[31m#\033[0m" 
        else
          grid[p.y][p.x] = 'O'
        end
      end
    end
    puts grid.map{|r| r.join }.join("\n")
  end
  Edge = Struct.new(:n1, :n2, :length) do
    def to_s
      "Edge: n1=#{self.n1} n2=#{self.n2} d=#{self.length}"
    end
    def inspect
      to_s
    end
  end
  def neighbors(curr, visited)
    curr.neighbors(@rows, @cols).reject do |p|
      @grid[p.y][p.x] == '#' ||
      visited.include?(p) ||
      ( !@slopes_normal && @grid[curr.y][curr.x] == '.' &&
          ( (@grid[p.y][p.x] == '>' && p.x < curr.x) ||
            (@grid[p.y][p.x] == '<' && p.x > curr.x) ||
            (@grid[p.y][p.x] == '^' && p.y > curr.y) ||
            (@grid[p.y][p.x] == 'v' && p.y < curr.y) )
      ) ||
      ( !@slopes_normal && (
        (@grid[curr.y][curr.x] == '>' && (p.y != curr.y || p.x != (curr.x + 1))) ||
        (@grid[curr.y][curr.x] == '<' && (p.y != curr.y || p.x != (curr.x - 1))) ||
        (@grid[curr.y][curr.x] == '^' && (p.x != curr.x || p.y != (curr.y - 1))) ||
        (@grid[curr.y][curr.x] == 'v' && (p.x != curr.x || p.y != (curr.y + 1))) ) ) 
    end
  end
  def find_nodes
    @nodes = Set.new [@start]
    @rows.times do |y|
      @cols.times do |x|
        next if @grid[y][x] == '#'
        p = Point.new(x,y)
        ns = p.neighbors(@rows, @cols).reject do |p|
          @grid[p.y][p.x] == '#'
        end
        @nodes << p if ns.size > 2
      end
    end
    @nodes << @finish
  end
  def find_edges(start_pt, visited = Set.new, start_node = @start)
    @edges ||= Set.new
    if @edges.any?{|e| e.n1 == start_pt}
      return
    end
    length = start_pt == @start ? 0 : 1
    queue = [start_pt]
    while queue.size > 0
      curr = queue.pop
      visited << curr
      length += 1
      ns = neighbors(curr, visited)
      raise "FOUND MORE THAN ONE NEIGHBOR" if ns.size > 1
      if ns.size == 1
        next_pt = ns[0]
        if @nodes.include?(next_pt)
          edge = Edge.new(start_node, next_pt, length)
          #edge2 = Edge.new(next_pt, start_node, length)
          #if @edges.include?(edge2)
          #  if edge.n1.y < edge2.n1.y
          #    raise "FOUND ANOTHER EDGE IN OPPOSITE DIRECTION: ME: #{edge} THEM: #{edge2}"
          #  end
          #end
          unless @edges.include?(edge)
            @edges << edge
            debug { "FOUND EDGE: #{edge}\n" }
            ns = neighbors(next_pt, visited)
            ns.each do |branch_pt|
              find_edges(branch_pt, Set.new([curr, next_pt]), next_pt)
            end
          end
        else
          queue << next_pt
        end
      end
    end
  end
  def find_neighbors(pt)
    @edges.find_all do |e|
      e.n1 == pt
    end.map(&:n2)
  end
  def topo_sort
    in_degrees = Hash.new{|h,k| h[k] = 0}
    @nodes.each do |pt|
      in_degrees[pt] = @edges.count { |e| e.n2 == pt }
    end
    debug { "IN DEGREES: #{in_degrees.inspect}\n" }
    queue = []
    in_degrees.each do |pt, in_deg|
      queue << pt if in_deg == 0
    end
    debug { "QUEUE: #{queue}\n" }
    sort_list = Hash.new{|h,k| h[k] = 0}
    while !queue.empty?
      v = queue.shift
      sort_list[v] == 0
      e_ns = find_neighbors(v)
      debug { "Neighbors of #{v}: #{e_ns}\n" }
      e_ns.each do |u|
        in_degrees[u] -= 1
        if in_degrees[u] == 0
          queue << u
        end
      end
    end
    debug { "Sorted: #{sort_list.keys}\n" }
    raise "There is a cycle in the graph" if sort_list.size != @nodes.size
    sort_list
  end
  def longest_path(nodes)
    nodes.each.with_index do |(u, dist), i|
      ns = find_neighbors(u)
      ns.each do |v|
        edge = @edges.find {|e| e.n1 == u && e.n2 == v}
        nodes[v] = [nodes[v], nodes[u] + edge.length].max
      end
    end
    debug { "NODES: #{nodes.inspect}\n" }
    nodes[@finish]
  end
  def nodify_point(p)
    "n#{p.to_s.sub('(', '').sub(')', '').sub(',', '')}"
  end
  def gen_dot
    File.open("foo.dot", "w") do |f|
      f.puts "digraph {"
      @nodes.each do |p|
        f.puts nodify_point(p)
      end
      @nodes.each do |p|
        find_neighbors(p).each.with_index do |np, idx|
          e = @edges.find {|e| e.n1 == p && e.n2 == np}
          f.puts "#{nodify_point(p)} -> #{nodify_point(np)} [label=\"#{e.length || 'WTF'}\"];"
        end
      end
      f.puts "}"
    end
  end
  def setup
    parse
    debug { "ROWS: #{@rows} COLS: #{@cols} START: #{@start} FINISH: #{@finish}\n" }
    find_nodes
    debug { "NODES: #{@nodes.size}\n" }
    debug { print_path(@nodes); "" }
    find_edges(@start)
    debug { "EDGES: #{@edges.size}\n" }
    gen_dot
  end
  def part1
    setup
    sorted = topo_sort
    longest_path(sorted)
  end
  def part2
    @slopes_normal = true
    setup
    part2_longest
    @max_length
  end
  def part2_longest
    @max_length = 0
    visited = Set.new([@start])
    @calls = 0
    part2_longest_dfs(@start, visited, 0)
  end
  def part2_longest_dfs(node, visited, current_length)
    @calls += 1
    if @calls % 1_000_000 == 0
      debug { "#{@calls / 1_000_000}M calls, max so far: #{@max_length}\n" }
    end
    if node == @finish
      @max_length = [@max_length, current_length].max
      return
    end
    nes = @edges.find_all do |e|
      e.n1 == node
    end
    nes.sort_by{|e| -e.length}.each do |e|
      if !visited.include?(e.n2)
        visited << e.n2
        part2_longest_dfs(e.n2, visited, current_length + e.length)
        visited.delete(e.n2)
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
