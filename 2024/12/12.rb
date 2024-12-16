require_relative '../../common/point'
def flood(grid, rows, cols, visited, p, char, orth = false)
  points = [p]
  visited[p] = true
  queue = orth ? p.orth_n_of_char(grid,char,rows,cols) : p.n_of_char(grid,char,rows,cols)
  while !queue.empty?
    #debug "FLOOD: #{queue.inspect}\n"
    p = queue.pop
    points << p
    visited[p] = true
    queue.concat (orth ? p.orth_n_of_char(grid,char,rows,cols) : p.n_of_char(grid,char,rows,cols)).reject{|p| visited[p] || queue.include?(p)}
  end
  points
end
class Point
  def orth_ns(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols}
  end
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1),
      Point.new(self.x - 1, self.y - 1),
      Point.new(self.x + 1, self.y + 1),
      Point.new(self.x + 1, self.y - 1),
      Point.new(self.x - 1, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols}
  end
  def orth_n_of_char(grid, char, rows, cols)
    orth_ns(rows, cols).reject{|p| grid[p.y][p.x] != char}
  end
  def n_of_char(grid, char, rows, cols)
    neighbors(rows, cols).reject{|p| grid[p.y][p.x] != char}
  end
  def matches_char(grid, char)
      self.y >= 0 && self.x >= 0 && self.y < grid.size && self.x < grid[0].size && grid[self.y][self.x] == char
  end
end
Region = Struct.new(:points, :area, :perimeter, :char) do |clazz|
  def interior_sides(grid)
    # special case, single block
    if points.size == 1
      return 0
    end
    #bounding box
    minx = points.map(&:x).min
    maxx = points.map(&:x).max
    miny = points.map(&:y).min
    maxy = points.map(&:y).max
    rows = maxy - miny + 3
    cols = maxx - minx + 3
    bbgrid = []
    rows.times { bbgrid << (['.'] * cols)}
    points.each {|p| bbgrid[p.y - miny + 1][p.x - minx + 1] = char}
    visited = Hash.new{|h,k| h[k] = false}
    bbfloodpts = flood(bbgrid, rows, cols, visited, Point.new(0,0), '.', false)
    #puts "BBGRID:"
    #puts bbgrid.map{|r| r.join}.join("\n")
    #puts "FLOOD: #{bbfloodpts.inspect}"
    interior = []
    bbgrid.size.times do |y|
      bbgrid[0].size.times do |x|
        p = Point.new(x,y)
        if bbgrid[y][x] != char && !visited[p]
          interior << p
        end
      end
    end
    interior_groups = [[]]
    new_interior = []
    while !interior.empty? || !new_interior.empty?
      p = interior.shift
      ig = interior_groups.last
      if ig.empty?
        ig << p
      else
        if ig.any?{|igp| (p.x-igp.x).abs <= 1 && (p.y-igp.y).abs <= 1}
          ig << p
        else
          new_interior << p
        end
      end
      if interior.empty? && !new_interior.empty?
        interior_groups << []
        interior, new_interior = new_interior, interior
      end
    end
    interior_sides = 0
    interior_groups.each do |ig|
      next if ig.empty?
      interior_region = Region.new(ig, ig.size, 0, '.')
      interior_sides += interior_region.sides(bbgrid, false)
    end
    interior_sides
  end
  def sides(grid, orth = true)
    tlpoint = points.min_by{|p| p.mag2}
    x = tlpoint.x
    y = tlpoint.y
    p = Point.new(x, y)
    op = Point.new(x, y)
    char = grid[y][x]
    # special case of a one block region
    if p.n_of_char(grid, char, grid.size, grid[0].size) == 0
      return 4
    end
    sides = 1
    dir = 0
    dy = [1, 0, -1, 0]
    dx = [0, 1, 0, -1]
    fry = [1, 1, -1, -1]
    frx = [-1, 1, 1, -1]
    loop do
      np = Point.new(p.x+dx[dir], p.y+dy[dir])
      npfr = Point.new(p.x+frx[dir], p.y+fry[dir])
      if np.matches_char(grid, char)
        if npfr.matches_char(grid, char)
          dir = (dir + 3) % 4
          sides += 1
          p = npfr
        else
          p = np
        end
      else
        if !orth && npfr.matches_char(grid, char)
          dir = (dir + 3) % 4
          sides += 1
          p = npfr
        else
          dir = (dir + 1) % 4
          sides += 1
        end
      end
      #puts "#{char}: SIDES: #{sides} p=#{p} op=#{op}"
      #print_grid(grid, p)
      break if p == op and dir == 3
    end
    sides
  end
  def print_grid(grid, p = nil)
    grid = Marshal.load(Marshal.dump(grid))
    if p
      grid[p.y][p.x] = '*'
    end
    puts grid.map{|l| l.join}.join("\n")
  end
end
class Solution
  def parse_grid
    grid = ARGF.each_line.map{|l| l.chomp.split(//)}
    [grid, grid.size, grid[0].size]
  end
  def print_grid(grid, p = nil)
    grid = Marshal.load(Marshal.dump(grid))
    if p
      grid[p.y][p.x] = '*'
    end
    grid.map{|l| l.join}.join("\n")
  end
  def part1
    grid, rows, cols = parse_grid
    visited = Hash.new{|h,k| h[k] = false}
    regions = []
    rows.times do |y|
      cols.times do |x|
        p = Point.new(x,y)
        next if visited[p]
        char = grid[y][x]
        points = flood(grid, rows, cols, visited, p, char, true)
        perim = points.inject(0) do |per, p|
          per += (4 - p.orth_n_of_char(grid,char,rows,cols).size)
        end
        regions << Region.new(points, points.size, perim, char)
      end
    end
    regions.map do |r|
      debug "REGION: #{r.char}: area: #{r.area} perimeter: #{r.perimeter}\n"
      cost = r.area * r.perimeter
    end.sum
  end
  def part2
    grid, rows, cols = parse_grid
    visited = Hash.new{|h,k| h[k] = false}
    regions = []
    cost = 0
    rows.times do |y|
      cols.times do |x|
        p = Point.new(x,y)
        next if visited[p]
        char = grid[y][x]
        points = flood(grid, rows, cols, visited, p, char, true)
        r = Region.new(points,points.size,0,char)
        regions << r
        debug "REGION: #{r.char}: area: #{r.area} sides: #{r.sides(grid)} interior sides: #{r.interior_sides(grid)}\n"
        cost += r.area * (r.sides(grid) + r.interior_sides(grid))
      end
    end
    cost
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
