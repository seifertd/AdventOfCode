class Solution
  def parse
    @nodes = []
    @edges = []
    input do |line|
      n1, _, n2, _, d = line.split(' ')
      d = d.to_i
      @nodes << n1 << n2
      @edges << [n1, n2, d] 
    end
    @nodes.uniq!
  end
  def part1
    parse
    extreme_path(:min)
  end
  def extreme_path(minmax)
    @extreme_len = minmax == :min ? 1_000_000 : 0
    @nodes.each do |first_node|
      visited = Set.new([first_node])
      path = [first_node]
      extreme_path_dfs(minmax, first_node, visited, 0, path)
    end
    @extreme_len
  end
  def extreme_path_dfs(minmax, node, visited, curr_len, path)
    if visited.size == @nodes.size
      @extreme_len = [@extreme_len, curr_len].send(minmax)
      return
    end
    nes = @edges.find_all do |e|
      e[0] == node || e[1] == node
    end
    nes.sort_by{|e| minmax == :min ? e[2] : -e[2] }.each do |e|
      nn = e[0] == node ? e[1] : e[0]
      if !visited.include?(nn)
        visited << nn
        path << nn
        extreme_path_dfs(minmax, nn, visited, curr_len + e[2], path)
        path.pop
        visited.delete(nn)
      end
    end
  end
  def part2
    parse
    extreme_path(:max)
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
