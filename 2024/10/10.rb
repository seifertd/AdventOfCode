require '../../common/point'

class Point
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols}
  end
end

class Solution
  def parse_grid
    grid = ARGF.each_line.map{|l| l.chomp.split(//).map(&:to_i)}
    starts = []
    grid.each.with_index do |row, y|
      row.each.with_index do |c, x|
        if c == 0 
          starts << Point.new(x, y)
        end
      end
    end
    [grid, starts]
  end
  def print_grid(grid)
    puts grid.map{|r| r.join}.join("\n")
  end
  def find_path(grid, path, collect = [])
    p = path.last
    pval = grid[p.y][p.x]
    if pval == 9
      collect << path
      return collect
    end
    next_ps = p.neighbors(grid.size, grid[0].size).select do |p|
      grid[p.y][p.x] == pval + 1
    end
    if next_ps.empty?
      return collect
    end
    next_ps.each do |np|
      find_path(grid, path + [np], collect)
    end
    collect
  end
  def part1
    grid, starts = parse_grid
    paths = starts
    endpoints = starts.map{|s| find_path(grid, [s])}
    score = 0
    starts.each.with_index do |s, idx|
      eps = endpoints[idx].map{|p| p.last}.uniq
      debug "START: #{s}: unique eps: #{eps.size}\n"
      score += eps.size
    end
    score
  end
  def part2
    grid, starts = parse_grid
    paths = starts
    endpoints = starts.map{|s| find_path(grid, [s])}
    score = 0
    starts.each.with_index do |s, idx|
      eps = endpoints[idx]
      debug "START: #{s}: unique paths: #{eps.size}\n"
      score += eps.size
    end
    score
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
