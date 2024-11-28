Plan = Struct.new(:dir, :units, :color)
Dig = Struct.new(:plan, :grid, :rows, :cols, :dig_x, :dig_y, :boundary) do
  def initialize
    self.plan = []
    self.boundary = []
  end

  def reset(rows, cols, dig_x, dig_y)
    self.rows = rows
    self.cols = cols
    self.dig_x = dig_x
    self.dig_y = dig_y
    one_row = ['.'] * self.cols
    self.grid = []
    self.boundary = []
    rows.times do 
      self.grid << one_row.dup
      self.boundary << [false] * self.cols
    end
    self.grid[dig_y][dig_x] = '#'
    self.boundary[dig_y][dig_x] = true
  end

  def inside?(y, x)
    #puts "POINT #{y},#{x} INSIDE?"
    crossings = 0
    cx = 0
    while cx < x
      #print "(#{y},#{cx}) crossings: #{crossings}: "
      if self.boundary[y][cx]
        if y > 0 && y < self.rows - 1 && self.boundary[y-1][cx] && self.boundary[y+1][cx]
          # crossing a vertical wall
          #puts "Vertical crossing"
          crossings += 1
        else
          # crossing a horizontal wall
          corner_1 = if y > 0 && self.boundary[y-1][cx]
                 # up to right turn
                 :ccw
               elsif y < self.rows - 2 && self.boundary[y+1][cx]
                 # down to right turn
                 :cw
               end
          #print " c1(@x=#{cx}) is #{corner_1.inspect}."
          dx = 1
          while cx + dx < self.cols && cx + dx < x && self.boundary[y][cx+dx]
            # traversing the horizontal wall
            dx += 1
          end
          #print " horizontal wall len #{dx}"
          cx += (dx-1)
          corner_2 = if y > 0 && self.boundary[y-1][cx]
                 # left to up
                 :ccw
               elsif y < self.rows - 2 && self.boundary[y+1][cx]
                 # left to down
                 :cw
               end
          #puts " c2(@x=#{cx}) is #{corner_1.inspect}."
          if corner_1 == corner_2
            crossings += 2
          else
            crossings += 1
          end
        end
      end
      cx += 1
    end
    #puts " CROSSINGS: #{crossings} ODD? #{crossings.odd?}"
    crossings.odd?
  end

  def area
    vol = 0
    #4.times do |y|
    self.rows.times do |y|
      self.cols.times do |x|
        if self.boundary[y][x]
          vol += 1
        else
          if self.inside?(y, x)
            vol += 1
          end
        end
      end
      #puts "After row #{y+1}, vol=#{vol}"
    end
    vol
  end

  def inspect
    puts "Dig: rows=#{self.rows} cols=#{self.cols} digy=#{self.dig_y},digx=#{self.dig_x}"
    puts self.grid.map(&:join).join("\n")
  end

  def execute
    self.plan.each do |d|
      dx = dy = 0
      dx = 1 if d.dir == 'R'
      dx = -1 if d.dir == 'L'
      dy = 1 if d.dir == 'D'
      dy = -1 if d.dir == 'U'
      d.units.times do
        self.dig_x += dx
        self.dig_y += dy
        self.grid[dig_y][dig_x] = '#'
        self.boundary[dig_y][dig_x] = true
      end
    end
  end
end

def parse_dig
  dig = Dig.new
  max_x = max_y = 0
  min_x = min_y = 0
  x = y = 0
  ARGF.each_line do |line|
    line.chomp!
    p = Plan.new
    dir, units, color = line.split(" ")
    dig.plan << Plan.new(dir, units.to_i, color.gsub(/[\(\)]/, ''))
    if dir == 'R'
      x += units.to_i
      max_x = [max_x, x].max
    elsif dir == 'L'
      x -= units.to_i
      min_x = [min_x, x].min
    elsif dir == 'D'
      y += units.to_i
      max_y = [max_y, y].max
    else
      y -= units.to_i
      min_y = [min_y, y].min
    end
    #puts "After parsing #{dir}:#{units}, x=#{x}(#{min_x}->#{max_x}), y=#{y}(#{min_y}->#{max_y})"
  end
  cols = max_x - min_x + 1
  rows = max_y - min_y + 1
  x -= min_x
  y -= min_y
  dig.reset(rows, cols, x, y)
  dig
end

dig = parse_dig

def part1(dig)
  debug = (ENV['DEBUG'] || '').include?('part1')
  dig.execute
  puts dig.inspect if debug
  dig.area
end

Dig2 = Struct.new(:rows, :cols) do
  def initialize
    self.rows = Hash.new{|h,k| h[k] = []}
    self.cols = Hash.new{|h,k| h[k] = []}
  end
  def add_horizontal(y, x, len)
    self.rows[y] << [x, len]
    self.rows[y] = self.rows[y].sort_by{|x,len| x}
  end
  def add_vertical(x, y, len)
    self.cols[x] << [y, len]
    self.cols[x] = self.cols[x].sort_by{|y,len| y}
  end

  def col_intersects?(col, x, y)
  end

  def len_row(y)
  end

  def len_row_plus(y)
  end

  def area
    rows = self.rows.keys.sort
    cols = self.cols.keys.sort
    area = 0
    rows.each do |y|
      area += len_row(y)
      area += len_row_plus(y+1) * 
      x = cols.first
      inside = false
      len = 0
      cols.each do |cx|
        self.cols[cx].each do |ci|
          if col_intersects?(ci, y, cx)
            inside = !inside
            break
          end
        end
        if inside
          len += (cx - x)
        end
        x = cx

    end
  end
end

def parse_dig2(dig)
  dig2 = Dig2.new
  if ENV['DEBUG'] == 'part2_test'
  dig2.add_horizontal(0, 0, 7)
  dig2.add_vertical(6, 0, 6)
  dig2.add_horizontal(5, 4, 3)
  dig2.add_vertical(4, 5, 3)
  dig2.add_horizontal(7, 4, 3)
  dig2.add_vertical(6, 7, 3)
  dig2.add_horizontal(9, 1, 6)
  dig2.add_vertical(1, 7, 3)
  dig2.add_horizontal(7, 0, 2)
  dig2.add_vertical(0, 5, 3)
  dig2.add_horizontal(5, 0, 3)
  dig2.add_vertical(2, 2, 4)
  dig2.add_horizontal(2, 0, 3)
  dig2.add_vertical(0, 0, 3)
  return dig2
  end
  dirs = ['R', 'D', 'L', 'U']
  x = y = 0
  dig.plan.each do |p|
    units = p.color[1..-2].to_i(16)
    dir = dirs[p.color[-1].to_i]
    #puts "Dig #{dir}: #{units} #{p.color}"
    if dir == 'R'
      dig2.add_horizontal(y, x, units)
      x += units
    elsif dir == 'D'
      dig2.add_vertical(x, y, units)
      y += units
    elsif dir == 'L'
      dig2.add_horizontal(y, x - units, units)
      x -= units
    else
      dig2.add_vertical(x, y - units, units)
      y -= units
    end
  end
  raise "Didn't get back to origin: #{y},#{x}" if x != 0 && y != 0
  dig2
end

dig2 = parse_dig2(dig)

def part2(dig2)
  dig2.area
end

puts "Part 1: #{part1(dig)}"
puts "Part 2: #{part2(dig2)}"
