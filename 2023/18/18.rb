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

  def get_width(y1, rs, cs)
    #puts "GET WIDTH y1=#{y1}"
    w = 0
    crossings = 0
    h_segs = self.rows[y1].dup
    xi = 0
    while xi <= self.cols.length - 2 
      x = cs[xi]
      h_seg = h_segs[0]
      if !h_seg.nil?
        #while x < h_seg.first
        #  xi += 1
        #  x = cs[xi]
        #end
        lvert = self.cols[x].find{|lvy, lvlen| lvy == y1 || (lvy+lvlen-1) == y1}
        if !lvert.nil?
          puts "HANDLING H_SEG = #{h_seg.inspect}" if ENV['DEBUG'] == 'part2'
          puts "lvert = #{lvert.inspect} cols@#{x}=#{self.cols[x].inspect}" if ENV['DEBUG'] == 'part2'
          h_segs.shift
          xi += 1
          x = cs[xi]
          while xi < cs.length && cs[xi] < (h_seg.first + h_seg.last)
            puts "ITERATING #{xi}:#{cs[xi]} cs.length=#{cs.length} target x: #{h_seg.first + h_seg.last}" if ENV['DEBUG'] == 'part2'
            xi += 1
            x = cs[xi]
            puts "ITERATING #{xi}:#{cs[xi]} cs.length=#{cs.length} target x: #{h_seg.first + h_seg.last}" if ENV['DEBUG'] == 'part2'
          end
          w += (h_seg.last - 1)
          xi -= 1
          x = cs[xi]
          puts "AFTER TRAVERSING HSEG #{h_seg.inspect}, xi = #{xi}, x = #{x} W=#{w} cs.len=#{cs.length}" if ENV['DEBUG'] == 'part2'
          if xi >= cs.length - 1
            # Add the last column back in
            w += 1
            return w
          end
          puts "CHECKING #{x} against #{h_seg.inspect}: COLS: #{self.cols[x].inspect}" if ENV['DEBUG'] == 'part2'
          while x < (h_seg.first + h_seg.last - 1)
            xi += 1
            x = cs[xi]
            puts "CHECKING #{x} against #{h_seg.inspect}: COLS: #{self.cols[x].inspect}" if ENV['DEBUG'] == 'part2'
          end
          rvert = self.cols[x].find{|lvy, lvlen| lvy == y1 || (lvy+lvlen-1) == y1}
          raise "COULD NOT FIND RIGHT VERT SEGMENT MATCHING HORIZONTAL SEGMENT: #{h_seg.inspect} @y=#{y1},x=#{x}, CANDIDATES: #{self.cols[x].inspect}" if rvert.nil?
          puts "rvert = #{rvert} cols@#{x}=#{self.cols[x].inspect}" if ENV['DEBUG'] == 'part2'
          if !(lvert.first < y1 && rvert.first == y1 || lvert.first == y1 && rvert.first < y1)
            crossings += 1
          end
        end
      end
      self.cols[x].each do |xy, seg_h|
        print "Y1=#{y1} XI=#{xi} X=#{x}, X+1=#{cs[xi+1]} XY=#{xy}" if ENV['DEBUG'] == 'part2'
        if xy < y1 && y1 < (xy+seg_h) || xy == y1
          crossings += 1
          print " CROSSING #{xi}->#{xi+1}: #{crossings}" if ENV['DEBUG'] == 'part2'
        else
          print " NOT CROSSING #{crossings}" if ENV['DEBUG'] == 'part2'
        end
      end
      if crossings.odd?
        delta_w = cs[xi+1] - cs[xi]
        w += delta_w
        print " W += #{delta_w} W = #{w}" if ENV['DEBUG'] == 'part2'
      end
      puts if ENV['DEBUG'] == 'part2'
      xi += 1
    end
    # Last column
    w += 1
    w
  end

  def volume
    rs = self.rows.keys.sort
    cs = self.cols.keys.sort
    vol = 0
    0.upto(self.rows.length - 2) do |yi1|
      y1 = rs[yi1]
      #puts "Y1=#{y1}"
      # Count current row first
      y1_width = get_width(y1, rs, cs)
      vol += y1_width
      puts "YI1=#{yi1} Y1=#{y1} H=1 W=#{y1_width} V=#{vol}" if ENV['DEBUG'] == 'part2'
      y1 += 1
      y2 = rs[yi1+1]
      if y1 == y2
        # if we meet next row, continue
        next
      end
      # count all rows beneath y1 upto but not including y2
      h = y2 - y1 
      #puts "Y1=#{y1},Y2=#{y2},H=#{h} "
      w = get_width(y1, rs, cs)
      vol += (h * w)
      puts "YI1=#{yi1} Y1=#{y1} W=#{w} H=#{h} V += #{h*w} V = #{vol}" if ENV['DEBUG'] == 'part2'
    end
    # Last row
    vol += get_width(rs.last, rs, cs)
    vol
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
  dig2.volume
end

puts "Part 1: #{part1(dig)}"
puts "Part 2: #{part2(dig2)}"
