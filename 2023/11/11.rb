Map = Struct.new(:grid, :rows, :cols, :galaxies) do
  def taxi_dist(p1, p2)
    (p1.first - p2.first).abs + (p1.last - p2.last).abs
  end
  def taxi_dist_with_expansion(p1, p2, ex)
    ers = self.empty_rows
    ecs = self.empty_cols
    xrange = p1.last < p2.last ? (p1.last..p2.last) : (p2.last..p1.last)
    yrange = p1.first < p2.first ? (p1.first..p2.first) : (p2.first..p1.first)

    num_ec = ecs.count do |ec|
      xrange.include?(ec)
    end
    num_er = ers.count do |er|
      yrange.include?(er)
    end
    (p1.first - p2.first).abs + (num_ec*(ex-1)) + (p1.last - p2.last).abs + (num_er*(ex-1)) 
  end
  def empty_rows
    @empty_rows ||= begin
      rows = []
      (0...self.rows).each do |y|
        if !self.grid[y].any? {|c| c == '#' }
          rows << y
        end
      end
      rows
    end
  end
  def empty_cols
    @empty_cols ||= begin
      cols = []
      (0...self.cols).each do |x|
        has_galaxy = false
        (0...self.rows).each do |y|
          if self.grid[y][x] == '#'
            has_galaxy = true
            break
          end
        end
        if !has_galaxy
          cols << x
        end
      end
      cols
    end
  end
  def expand
    new_map = Map.new
    new_map.grid = Marshal.load(Marshal.dump(self.grid))
    new_map.rows = self.rows
    new_map.cols = self.cols
    ec = new_map.empty_cols
    ec.each.with_index do |x, idx|
      new_map.cols += 1
      (0...new_map.rows).each do |y|
        new_map.grid[y].insert(x + idx, '.')
      end
    end
    er = new_map.empty_rows
    er.each.with_index do |y, idx|
      new_map.rows += 1
      new_map.grid.insert(y + idx, ['.'] * self.cols)
    end
    new_map.calc_galaxies
    new_map
  end
  def calc_galaxies
    self.galaxies = []
    (0...self.rows).each do |y|
      (0...self.cols).each do |x|
        if self.grid[y][x] == '#'
          self.galaxies << [y,x]
        end
      end
    end
  end
end

def parse_map
  map = Map.new
  map.grid = []
  map.galaxies = []

  map.rows = 0
  ARGF.each_line do |line|
    line.chomp!
    map.grid << line.split(//)
    map.cols ||= map.grid.last.size
    if map.cols != map.grid.last.size
      raise "Row #{map.rows} is not the same size as those before it"
    end
    map.rows += 1
  end
  map
end

map = parse_map

def part1(map)
  map = map.expand
  #puts map.inspect
  sum = 0
  n = map.galaxies.size
  0.upto(n-1) do |i|
    (i+1).upto(n-1) do |j|
      d = map.taxi_dist(map.galaxies[i], map.galaxies[j])
      #puts "DIST FROM GALAXY #{i+1} #{map.galaxies[i].inspect} -> #{j+1} #{map.galaxies[j].inspect} => #{d}"
      sum += d
    end
  end
  sum
end

def part2(map)
  map.calc_galaxies
  sum = 0
  n = map.galaxies.size
  0.upto(n-1) do |i|
    (i+1).upto(n-1) do |j|
      d = map.taxi_dist_with_expansion(map.galaxies[i], map.galaxies[j], 1_000_000)
      #puts "DIST FROM GALAXY #{i+1} #{map.galaxies[i].inspect} -> #{j+1} #{map.galaxies[j].inspect} => #{d}"
      sum += d
    end
  end
  sum
end

puts "Part 1: #{part1(map)}"
puts "Part 2: #{part2(map)}"
