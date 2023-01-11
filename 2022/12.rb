grid = nil
Point = Struct.new(:x, :y, :char, :height, :visited, :direction) do |clz|
  def initialize(x = 0, y = 0, char = nil)
    super(x, y, char)
    self.visited = false
    self.direction = nil
  end  
  def letter
    if self.direction 
      case self.direction
      when :down
        "\u{2193}"
      when :up
        "\u{2191}"
      when :left
        "\u{2190}"
      when :right
        "\u{2192}"
      end
    else
      self.char
    end
  end
  def to_s
    "(#{x},#{y},#{height.inspect}):#{visited}"
  end
  def eql?(o)
    x == o.x && y == o.y
  end
  def hash
    x.hash ^ y.hash
  end
end
start = Point.new
goal = Point.new
ARGF.each_line do |line|
  line.chomp!
  if grid.nil?
    grid = [[]]
  else
    grid << []
  end
  line.split(//).each do |c|
    p = Point.new(grid.last.size, grid.size - 1, c)
    if c == 'S'
      p.visited = true
      p.height = 'a'.ord
      start.x = p.x
      start.y = p.y
      start.height = p.height
    elsif c == 'E'
      p.height = 'z'.ord
      goal.x = p.x
      goal.y = p.y
      goal.height = p.height
    else
      p.height = c.ord
    end
    grid.last << p
  end
end

print_grid = -> {
  grid.each do |row|
    puts row.map(&:letter).join
  end
}

print_grid.call
path_from = {}

draw_path = ->(current) {
  path = [current]
  while prev = path_from[current]
    dir =
      if prev.x < current.x
        prev.direction = :right
      elsif prev.x > current.x
        prev.direction = :left
      elsif prev.y < current.y
        prev.direction = :down
      else
        prev.direction = :up
      end
    current = prev
    path.unshift prev
  end
  path
}

part = 2

if part == 1
  rows = (start.y..start.y)
  cols = (start.x..start.x)
else
  rows = (0...grid.size)
  cols = (0...grid.first.size)
end

ogrid = Marshal.load(Marshal.dump(grid))
min_path = 1_000_000
rows.each do |row|
  cols.each do |col|
    next unless ['a', 'S'].include?(grid[row][col].char)
    start = grid[row][col]
    puts "Start: #{start} Finish: #{goal}"
    queue = [start]
    path_from = {}
    g_score = Hash.new{|h,k| h[k] = 1_000_000 }
    g_score[start] = 0
    f_score = Hash.new{|h,k| h[k] = 1_000_000 }
    f_score[start] = 0
    reached_goal = false
    while queue.size > 0
      current = queue.min{|a, b| f_score[a] <=> f_score[b] }
      if current.eql?(goal)
        reached_goal = true
        break
      end
      #puts "Checking Current: #{current}"
      #puts "ROW: #{grid[current.y].map(&:letter).join}"

      queue.delete(current)
      neighbors = []
      if current.x > 0
        ln = grid[current.y][current.x - 1]
        neighbors << ln if ln.height - current.height <= 1
      end
      if current.x < grid.first.size - 1
        rn = grid[current.y][current.x + 1]
        neighbors << rn if rn.height - current.height <= 1
      end
      if current.y > 0
        tn = grid[current.y - 1][current.x]
        neighbors << tn if tn.height - current.height <= 1
      end
      if current.y < grid.size - 1
        bn = grid[current.y + 1][current.x]
        neighbors << bn if bn.height - current.height <= 1
      end
      for n in neighbors
        t_gscore = g_score[current] + (n.height - current.height)
        if t_gscore < g_score[n]
          path_from[n] = current
          g_score[n] = t_gscore
          cost = [0, n.height - current.height].max
          f_score[n] = t_gscore + cost
          if !queue.include?(n)
            queue << n
          end
        end
      end
    end

    if reached_goal
      path = draw_path.call(goal)
      puts "PATH: STEPS #{path.size - 1}" 
      print_grid.call
      min_path = [min_path, path.size - 1].min
    else
      puts "COULD NOT REACH GOAL!"
    end
    grid = ogrid.dup
    grid = Marshal.load(Marshal.dump(ogrid))
  end
end

puts "MIN PATH: #{min_path}"
