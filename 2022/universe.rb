# This is a failed experiment to create a auto expanding
# 3D grid that stores data in a single 1D array.
# Some bug in the expand code as points are added
# Way too much overkill when you can just assume
# 0 to max and do it with a 3D array, which is 
# easier to deal with.
class Universe
  BLOCK = 1
  INTERNAL = 2
  EXTERNAL = 4
  UNKNOWN = 8
  attr_reader :data, :min, :max
  def initialize(debug = false)
    @debug = debug
    @max = AdventOfCode::Point.new(-100,-100,-100)
    @min = AdventOfCode::Point.new(100,100,100)
    @data = []
  end
  def num_points
    @data.count {|v| v == BLOCK}
  end
  def length
    @max.x - @min.x + 1
  end
  def width
    @max.y - @min.y + 1
  end
  def height
    @max.z - @min.z + 1
  end
  def volume
    length * width * height
  end
  def edge?(xidx,yidx,zidx)
    xidx == 0 || xidx >= length - 1
      yidx == 0 || yidx >= width - 1
      zidx == 0 || zidx >= height - 1
  end
  # Return all points that are in interior air pockets
  def find_pockets
    pockets = []
    (@min.z..@max.z).each.with_index do |z, zidx|
      (@min.y..@max.y).each.with_index do |y, yidx|
        (@min.x..@max.x).each.with_index do |x, xidx|
          if pocket = inside_pocket_of(xidx, yidx, zidx)
            pockets << pocket
          end
        end
      end
    end
    pockets
  end
  def neighbors_of(x0,y0,z0)
    points = []
    xr = ([x0-1,0].max..[x0+1,length-1].min)
    yr = ([y0-1,0].max..[y0+1,width-1].min)
    zr = ([z0-1,0].max..[z0+1,height-1].min)
    zr.each {|z| points << [x0,y0,z] if z != z0 }
    yr.each {|y| points << [x0,y,z0] if y != y0 }
    xr.each {|x| points << [x,y0,z0] if x != x0 }
    points
  end
  def inside_pocket_of(x0,y0,z0)
    data_idx0 = didx(x0,y0,z0)
    #puts "CHECKING IF #{x0},#{y0},#{z0} is a pocket, data=#{@data[data_idx0]}"
    if @data[data_idx0] > 0
      return nil
    end
    state = edge?(x0,y0,z0) ? EXTERNAL : UNKNOWN
    @data[data_idx0] |= state
    pocket = [AdventOfCode::Point.new(x0,y0,z0)]
    stack = []
    add_neighbors = lambda do |x0,y0,z0|
      neighbors_of(x0,y0,z0).each do |x,y,z|
        next if @data[didx(x,y,z)] > 0
        stack << [x,y,z]
      end
    end
    add_neighbors.call(x0,y0,z0)
    while !stack.empty?
      x,y,z = stack.shift
      data_idx = didx(x,y,z)
      #puts "  -> CHECKING #{x},#{y},#{z}, data: #{@data[data_idx]}"
      if @data[data_idx] == 0
        state = EXTERNAL if edge?(x,y,z)
        @data[data_idx] = UNKNOWN
        pocket << AdventOfCode::Point.new(x,y,z)
        add_neighbors.call(x,y,z)
      end
    end
    state = INTERNAL if state == UNKNOWN
    pocket.each { |p| @data[didx(p.x,p.y,p.z)] |= state }
    if state == INTERNAL
      pocket
    else
      nil
    end
  end
  def add_point(p)
    puts "ADDING #{p}" if @debug
    if @data.size > 0
      new_max = AdventOfCode::Point.new(-100,-100,-100)
      new_min = AdventOfCode::Point.new(100,100,100)
      new_max.x = [@max.x, p.x].max
      new_min.x = [@min.x, p.x].min
      new_max.y = [@max.y, p.y].max
      new_min.y = [@min.y, p.y].min
      new_max.z = [@max.z, p.z].max
      new_min.z = [@min.z, p.z].min
      # Expand z
      if new_min.z < @min.z
        puts "  <- expand z min" if @debug
        (@min.z - new_min.z).times { @data.unshift(*([0]*xy_size)) }
      end
      if new_max.z > @max.z
        puts "  <- expand z max" if @debug
        (new_max.z - @max.z).times { @data.push(*([0]*xy_size)) }
      end
      @min.z = new_min.z
      @max.z = new_max.z
      # Expand y
      if new_min.y < @min.y
        puts "  <- expand y min" if @debug
        num = @min.y - new_min.y
        # iterate in reverse order of z so we don't mess up z index
        zwidth = @max.z - @min.z + 1
        zwidth.times do |i|
          zidx = zwidth - 1 - i
          data_idx = zidx * xy_size
          @data.insert(data_idx, *([0] * xy_width * num))
        end
        @min.y = new_min.y
      end
      if new_max.y > @max.y
        num = new_max.y - @max.y
        puts "  <- expand y max by #{num} xy_width=#{xy_width} xy_size=#{xy_size}" if @debug
        # iterate in reverse order of z so we don't mess up z index
        zwidth = @max.z - @min.z + 1
        zwidth.times do |i|
          zidx = zwidth - 1 - i
          data_idx = zidx * xy_size + xy_size
          puts "  <- zidx=#{zidx} data_idx=#{data_idx}" if @debug
          @data.insert(data_idx, *([0] * xy_width * num))
        end
        @max.y = new_max.y
      end
      # Expand x
      if new_max.x > @max.x || new_min.x < @min.x
        num_l = @min.x - new_min.x
        num_r = new_max.x - @max.x
        puts "  <- expanding x: left: #{num_l} right: #{num_r}" if @debug
        zwidth = @max.z - @min.z + 1
        zwidth.times do |i|
          zidx = zwidth - 1 - i
          data_idx = zidx * xy_size
          puts "  <- for z=#{zidx}, data index = #{data_idx}, xy_width=#{xy_width}" if @debug
          ywidth = @max.y - @min.y + 1
          ywidth.times do |j|
            yidx = ywidth - 1 - j
            data_r_idx = data_idx + xy_width * (yidx + 1)
            puts "  <- for y=#{yidx}, data index = #{data_idx}, xy_width=#{xy_width} data_r_idx=#{data_r_idx}" if @debug
            @data.insert(data_r_idx, *([0]*num_r))
            @data.insert(data_idx, *([0]*num_l))
          end
        end
        @max.x = new_max.x
        @min.x = new_min.x
      end
    else
      @min.x = @max.x = p.x
      @min.y = @max.y = p.y
      @min.z = @max.z = p.z
      @data = [0]
    end
    puts "  -> IDX of #{p} = #{idx_of(p)}" if @debug
    raise "BLOCK ALREADY AT #{p}, idx=#{idx_of(p)}, @data=#{@data.inspect}" if (@data[idx_of(p)] & BLOCK) > 0
    @data[idx_of(p)] |= BLOCK
  end
  def []=(p,d)
    raise "x=#{p.x} out of bounds: #{@min.x}<=>#{@max.x}" if !(@min.x..@max.x).include?(p.x)
    raise "y=#{p.y} out of bounds: #{@min.y}<=>#{@max.y}" if !(@min.y..@max.y).include?(p.y)
    raise "z=#{p.z} out of bounds: #{@min.z}<=>#{@max.z}" if !(@min.z..@max.z).include?(p.z)
    @data[idx_of(x,y,z)] = d
  end
  def is_block?(xidx,yidx,zidx)
    ( @data[didx(xidx,yidx,zidx)] & BLOCK ) > 0
  end
  def [](p)
    raise "x=#{p.x} out of bounds: #{@min.x}<=>#{@max.x}" if !(@min.x..@max.x).include?(p.x)
    raise "y=#{p.y} out of bounds: #{@min.y}<=>#{@max.y}" if !(@min.y..@max.y).include?(p.y)
    raise "z=#{p.z} out of bounds: #{@min.z}<=>#{@max.z}" if !(@min.z..@max.z).include?(p.z)
    @data[idx_of(p)]
  end
  private
  def xy_width
    @max.x - @min.x + 1
  end
  def xy_size
    (@max.y - @min.y + 1) * (@max.x - @min.x + 1)
  end
  def xy_idx(p)
    xy_width * (p.y - @min.y) + (p.x - @min.x)
  end
  def idx_of(p)
    (p.z - @min.z) * self.xy_size + self.xy_idx(p)
  end
  def didx(xidx, yidx, zidx)
    zidx * self.xy_size + xy_width * yidx + xidx
  end
end
