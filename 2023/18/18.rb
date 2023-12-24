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

  def volume
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
  dig.volume
end

puts "Part 1:#{part1(dig)}"
