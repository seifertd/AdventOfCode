SYM_MAP = {
  '.' => '.',
  '-' => '─',
  '|' => '│',
  'L' => '└',
  'J' => '┘',
  '7' => '┐',
  'F' => '┌',
  'S' => '█'
}

# Map grid is rows. starting coord (y=0, x=0) is top left
Map = Struct.new(:rows, :cols, :start, :grid, :cycle) do
  def initialize
    super
    self.grid = []
    self.cycle = []
  end
  def char_at(coord)
    self.grid[coord.first][coord.last]
  end
  def in_cycle?(coord)
    self.cycle[coord.first][coord.last]
  end
  def print_cycle
    (0...self.rows).each do |y|
      (0...self.cols).each do |x|
        coord = [y,x]
        if self.in_cycle?(coord)
          print SYM_MAP[self.char_at(coord)]
        elsif self.inside(coord)
          print "\033[0;32m█\033[0m"
        else
          print "\033[0;31m█\033[0m"
        end
      end
      puts
    end
  end
  def connects_to(coord)
    # coordinates are always (y,x), y = rows, x = cols
    coords = []
    (-1..1).each do |dy|
      (-1..1).each do |dx|
        next if dx == 0 && dy == 0
        next if dx != 0 && dy != 0 # ignore diagonal
        y = coord.first + dy
        x = coord.last + dx
        next if y < 0 || y > self.rows - 1 || x < 0 || x > self.cols - 1
        c = self.grid[y][x]
        #puts "CHECKING coord=#{coord.inspect} dx=#{dx} dy=#{dy}, (y,x) = #{y},#{x}, c=#{c}"
        next if c == '.' 
        if dy < 0 && (c == '|' || c == 'F' || c == '7')
          coords << [y,x]
        elsif dy > 0 && (c == '|' || c == 'J' || c == 'L')
          coords << [y,x]
        elsif dx < 0 && (c == '-' || c == 'L' || c == 'F')
          coords << [y,x]
        elsif dx > 0 && (c == '-' || c == '7' || c == 'J')
          coords << [y,x]
        end
      end
    end
    coords
  end
  def inside(point, dirx = 1)
    # check if point is inside the cycle or not using 
    # the number of crossings by casting a horizontal
    # ray from the edge to the point in question
    if self.in_cycle?(point)
      false
    else
      crossings = 0
      check = dirx == 1 ? [point[0], 0] : [point[0], self.cols - 1]
      while check[1] < self.cols && check[1] >= 0 && ((dirx == 1 && check[1] <= point[1]) || (dirx == -1 && check[1] >= point[1]))
        if self.char_at(check) == 'S'
          # We hit the start point and don't know what kind of char it is
          # (because I am lazy), so go the other direction
          return inside(point, -dirx)
        end
        if self.in_cycle?(check) && ['F','7', '|'].include?(self.char_at(check))
          crossings += 1
        end
        check[1] += dirx
      end
      crossings.odd?
    end
  end
  def find_cycle
    cycle = [ self.start ]
    #puts "FOUND POINTS CONNECTING TO START #{self.start}"
    #self.connects_to(self.start).each do |point|
    #  puts "    Point: #{point.inspect} CHAR: #{self.char_at(point)}"
    #end
    next_point = self.connects_to(cycle.last).first
    cycle << next_point
    cur_idx = 1
    #puts "CYCLE: #{cycle.inspect}"
    while cycle[cur_idx] != cycle.first
      c = self.char_at(cycle[cur_idx])
      y = cycle[cur_idx].first
      x = cycle[cur_idx].last
      #puts "NEXT POINT #{cycle[cur_idx].inspect} = (#{y},#{x}) CHAR = #{c}"
      next_point = case
      when c == '|'
        [[y-1,x], [y+1, x]]
      when c == '-'
        [[y,x-1], [y,x+1]]
      when c == 'J'
        [[y-1,x], [y,x-1]]
      when c == 'F'
        [[y,x+1], [y+1,x]]
      when c == '7'
        [[y,x-1], [y+1,x]]
      when c == 'L'
        [[y,x+1], [y-1,x]]
      end.select do |y,x|
        !(y < 0 || y > self.rows - 1 || x < 0 || x > self.cols - 1)
      end.select do |c1|
        c1 != cycle[cur_idx-1]
      end
      #puts "NEXT POINT FOR #{y},#{x}: #{next_point.inspect}"
      raise "Could not find next point in the cycle" if next_point.nil?
      raise "Too many next points at #{cycle[cur_idx]}: #{next_point.inspect}" if next_point.size > 1
      cycle << next_point.first
      cur_idx += 1
      #puts "LOOP: #{cycle}"
    end
    cycle.each do |p|
      self.cycle[p[0]][p[1]] = true
    end
    cycle
  end
end

def parse_map
  map = Map.new
  y = 0
  ARGF.each_line do |line|
    line.chomp!
    map.grid << line.split(//)
    map.cycle << map.grid.last.map { |c| false }
    map.cols ||= map.grid.last.size
    raise "Map row has wrong number of cols" if map.cols != map.grid.last.size
    map.grid.last.each.with_index do |c, idx|
      if c == 'S'
        map.start = [y, idx]
      end
    end
    y += 1
  end
  map.rows = map.grid.size
  map
end

def part1(map)
  cycle = map.find_cycle
  (cycle.size - 1) / 2
end

def part2(map)
  cycle = map.find_cycle
  map.print_cycle
  inside = 0
  (0...map.rows).each do |y|
    (0...map.cols).each do |x|
      inside += 1 if map.inside([y,x])
    end
  end
  inside
end

map = parse_map
puts "Part 1: #{part1(map)}"
puts "Part 2: #{part2(map)}"
