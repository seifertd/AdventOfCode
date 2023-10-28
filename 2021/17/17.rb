#T_MIN_X = 20
#T_MAX_X = 30
#T_MIN_Y = -10
#T_MAX_Y = -5
T_MIN_X = 88 
T_MAX_X = 125 
T_MIN_Y = -157
T_MAX_Y = -103

ACC_Y = -1
DRAG_X = 1

Point = Struct.new(:x, :y)

def in_target(x,y)
  return x >= T_MIN_X && x <= T_MAX_X && y >= T_MIN_Y && y <= T_MAX_Y;
end

def simulate(vx, vy)
  coords = [Point.new(0,0)]
  x = y = 0
  while !in_target(x,y) && x <= T_MAX_X && y >= T_MIN_Y
    ax =
      if vx > 0
        -DRAG_X
      elsif vx < 0
        +DRAG_X
      else
        0
      end
    x = x + vx
    y = y + vy
    vx += ax
    vy += ACC_Y
    coords << Point.new(x, y)
  end
  return [in_target(x,y), coords]
end

solutions = []
map_data = []
vx = vy = nil
if ARGV.size == 2
  vx = ARGV[0].to_i
  vy = ARGV[1].to_i
end
global = nil
puts "VELOCITY SPACE:"
ymax = vy || -T_MIN_Y
ymin = vy || (T_MIN_Y - 1)
xmax = vx || (T_MAX_X + 1)
xmin = vx || 1
ymax.downto(ymin) do |vy|
  printf "%4d:", vy
  xmin.upto(xmax) do |vx|
    success, coords = simulate(vx, vy)
    if success
      print "#"
    else
      print "."
    end
    min_x = min_y = 1000
    max_x = max_y = -1000
    coords.each do |pt|
      min_x = [min_x, pt.x, T_MIN_X].min
      max_x = [max_x, pt.x, T_MAX_X].max
      min_y = [min_y, pt.y, T_MIN_Y].min
      max_y = [max_y, pt.y, T_MAX_Y].max
    end
    if success
      map_data << [vx, vy, max_y]
      solutions << [vx, vy, max_y, min_y, min_x, max_x, coords]
      if global.nil? || global[2] < max_y
        global = solutions.last
      end
    end
  end
  puts
end

=begin
# Failed experiment, heatmaps generated are not satisfying
require 'heatmap'
map = Heatmap.new
map_data.each do |sol|
  vx, vy, max_y = sol
  alpha = max_y.to_f / global[2]
  map <<  Heatmap::Area.new(vx - xmin, ymax - vy, alpha)
end
map.output('heatmap.png')
=end

puts "#{solutions.size} SOLUTIONS, max y = #{global[2]}"
#solutions.each do |p|
#  puts "vx:#{p[0]} vy:#{p[1]}"
#end

if global
  vx, vy, max_y, min_y, min_x, max_x, coords = global
  if max_y < 100
    max_y.downto(min_y) do |y|
      min_x.upto(max_x) do |x|
        if coords.any?{|pt| pt.x == x && pt.y == y}
          print '#'
        elsif y >= T_MIN_Y && y <= T_MAX_Y && x >= T_MIN_X && x <= T_MAX_X
          print 'T'
        else
          print '.'
        end
      end
      puts
    end
  end
  puts "Max Height: vx:#{vx} vy:#{vy}: max y:#{max_y}"
end
