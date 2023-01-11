require 'gosu'
require 'time'

SAND_COLOR = Gosu::Color.new(0xffc4a484)
DIRT_COLOR = Gosu::Color.new(0xffb5651d)

WALL = 1
DIRT = 2

Point = Struct.new(:x, :y) do |clz|
  def to_s
    "(#{x},#{y})"
  end
  def inspect
    to_s
  end
end

class Sand < Gosu::Window
  def initialize
    @block_size = 4
    @xmin = 480
    @xmax = 819
    @ymin = 0
    @ymax = 169
    @sand = []
    @cave = []
    @time = (Time.now.to_f * 1000).to_i
    @ymax.times do |r|
      @cave[r] = [0]*(@xmax-@xmin)
    end
    @start = Point.new(649 - @xmin,0)
    @screenx_min = 0
    @screenx_max = (@xmax - @xmin) * @block_size
    @screeny_max = @ymax * @block_size
    super @screenx_max, @screeny_max
    self.resizable = true
    self.caption = 'Sand'
    read_walls
  end
  def is_blocked?(x,y)
    @cave[y][x] > 0
  end
  def move_sand(sand)
    if !is_blocked?(sand.x,sand.y+1)
      sand.y += 1
      return true
    end
    if !is_blocked?(sand.x-1,sand.y+1)
      sand.y += 1
      sand.x -= 1
      return true
    end
    if !is_blocked?(sand.x+1, sand.y+1)
      sand.y += 1
      sand.x += 1
      return true
    end
    false
  end
  def update
    curtime = (Time.now.to_f * 1000).to_i
    if curtime - @time > 10
      @time = curtime
      if @cave[@start.y][@start.x] == 0
        @sand << Point.new(@start.x, @start.y)
      end
    end
    to_delete = []
    @sand.each.with_index do |sand,idx|
      if !move_sand(sand)
        @cave[sand.y][sand.x] |= DIRT
        to_delete << sand
      end
    end
    to_delete.each {|s| @sand.delete(s)}
  end
  def draw
    draw_rect(@start.x * @block_size, @start.y * @block_size, @block_size, @block_size, Gosu::Color::WHITE)
    @sand.each do |sand|
      draw_rect(sand.x * @block_size, sand.y * @block_size, @block_size, @block_size, SAND_COLOR)
    end
    @cave.each.with_index do |row, y|
      row.each.with_index do |mask, x|
        if (mask & WALL) > 0
          draw_rect(x * @block_size, y * @block_size, @block_size, @block_size, Gosu::Color::WHITE)
        elsif (mask & DIRT) > 0
          draw_rect(x * @block_size, y * @block_size, @block_size, @block_size, DIRT_COLOR)
        end
      end
    end
  end
  def read_walls
    segments = []
    ARGF.each_line do |line|
      line.chomp!
      segment = []
      line.scan(/(\d+),(\d+)( -> )?/) do |data|
        segment << Point.new(data[0].to_i - @xmin + 149, data[1].to_i)
      end
      segments << segment
    end
    segments << [Point.new(0, @ymax-1), Point.new(@xmax - @xmin - 1, @ymax-1)]
    segments.each do |seg|
      seg.each_cons(2) do |p1, p2|
        if p1.x == p2.x
          #vert
          y0,y1 = [p1.y,p2.y].sort
          (y0..y1).each {|y| @cave[y][p1.x] |= WALL}
        else
          #hori
          x0,x1 = [p1.x,p2.x].sort
          (x0..x1).each {|x| @cave[p1.y][x] |= WALL}
        end
      end
    end
  end
end

Sand.new.show
