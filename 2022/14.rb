DEBUG_SAND=(ENV['DEBUG_SAND'] || 1_000_000).to_i
part = 1
if ARGV.length > 0
  if ARGV[0].match(/^\d+$/)
    part = ARGV.shift.to_i
  end
end

Point = Struct.new(:x, :y) do |clz|
  def to_s
    "(#{x},#{y})"
  end
end

start = Point.new(500,0)
points = [start]
rsegs = []
ARGF.each_line do |line|
  line.chomp!
  segment = []
  line.scan(/(\d+),(\d+)( -> )?/) do |data|
    segment << Point.new(data[0].to_i, data[1].to_i)
  end
  rsegs << segment
  points.concat(segment)
end

puts "Read #{points.size} points, #{rsegs.size} rock segments"

if part == 1
  xmin = points.sort_by(&:x).first.x - 1
  xmax = points.sort_by(&:x).last.x + 1
  ymin = points.sort_by(&:y).first.y
  ymax = points.sort_by(&:y).last.y
else
  xmin = points.sort_by(&:x).first.x - 1
  xmax = points.sort_by(&:x).last.x + 1
  ymin = points.sort_by(&:y).first.y
  ymax = points.sort_by(&:y).last.y + 2
  # segment for floor, will auto extend
  rsegs << [Point.new(xmin, ymax), Point.new(xmax, ymax)]
end

h = ymax - ymin + 1
w = xmax - xmin + 1
puts "x: #{xmin}->#{xmax} #{w}"
puts "y: #{ymin}->#{ymax} #{h}"

cave = []
h.times.each do |row|
  cave[row] = ['.'] * w
end
cave[start.y-ymin][start.x-xmin] = '+'
rsegs.each do |seg|
  seg.each_cons(2) do |p1, p2|
    if p1.x == p2.x
      # vertical
      y0, y1 = [p1.y, p2.y].sort
      (y0..y1).to_a.each {|y| cave[y-ymin][p1.x-xmin] = '#'}
    else
      # horizontal
      x0, x1 = [p1.x, p2.x].sort
      (x0..x1).to_a.each {|x| cave[p1.y-ymin][x-xmin] = '#'}
    end
  end
end

print_cave = -> {
  h.times.each do |y|
    puts cave[y].join(" ")
  end
}

move_next = ->(sand, count) {
  if ['.', '~'].include?(cave[sand.y-ymin+1][sand.x-xmin])
    sand.y += 1
    return true
  end
  # Check left and extend cave if necessary
  if sand.x - xmin - 1 < 0
    puts "EXPAND LEFT" if count == DEBUG_SAND
    cave.size.times do |row|
      if row < cave.size - 1
        cave[row].unshift '.'
      else
        # extend floor
        cave[row].unshift '#'
      end
    end
    sand.x += 1
    start.x += 1
    xmax += 1
  end
  if ['.', '~'].include?(cave[sand.y-ymin+1][sand.x-xmin-1])
    sand.y += 1
    sand.x -= 1
    return true
  end
  # Check right and extend cave if necessary
  if sand.x + 1 > xmax
    puts "EXPAND RIGHT s.x:#{sand.x} xmax:#{xmax} row size #{cave.first.size} count: #{count}" if count == DEBUG_SAND
    cave.size.times do |row|
      if row < cave.size - 1
        cave[row].push '.'
      else
        # extend floor
        cave[row].push '#'
      end
    end
    xmax += 1
  end
  if ['.', '~'].include?(cave[sand.y-ymin+1][sand.x-xmin+1])
    sand.y += 1
    sand.x += 1
    return true
  end
  return false
}
# return number of ticks before coming to 
# rest or -1 if it falls through the bottom
drop_sand = ->(count) {
  ticks = 0
  sand = Point.new(start.x, start.y)
  puts "DROPPING SAND AT #{start}" if count == DEBUG_SAND
  while move_next.call(sand, count) do
    if count == DEBUG_SAND
      puts "SAND AFTER MOVE: #{sand}"
    end
    cave[sand.y-ymin][sand.x-xmin] = '~' if cave[sand.y-ymin][sand.x-xmin] == '.'
    ticks += 1 
    if sand.y >= ymax
      return [sand, ticks, true]
    end
  end
  cave[sand.y-ymin][sand.x-xmin] = 'o'
  if sand.y == 0
    return [sand, ticks, true]
  else
    return [sand, ticks, false]
  end
}

print_cave.call
puts "#{xmin}-------------------------------#{xmax}"
total_ticks = 0
sand_count = 0
fell = false

while !fell
  sand, ticks, fell = drop_sand.call(sand_count)
  total_ticks += ticks
  sand_count += 1 if !fell
  if sand_count == DEBUG_SAND
    print_cave.call if (xmax - xmin) < 80
    puts "#{xmin}-------------------------------#{xmax}"
    puts "#{sand_count}: ------------------------ : #{sand}"
  end
  exit 42 if sand_count > (DEBUG_SAND || 1_000_000)
end
if part == 2
  # Need to count the last sand grain as having fallen
  sand_count += 1
end
print_cave.call if (xmax - xmin) < 80
puts "#{sand_count}: #{xmin} #{xmax} #{ymin} #{ymax} start: #{start} ------------------------"
puts "Part 1: #{sand_count} units of sand came to rest"
