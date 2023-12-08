SAVE_ARGV = ARGV[0..-1]

Gear = Struct.new(:part1, :part2) do
  def ratio
    part1 * part2
  end
end

Schematic = Struct.new(:lines) do
  def initialize(lines = nil)
    self.lines = lines || []
  end
  def number_at(x0, y0)
    xb = nil
    xe = nil
    x = x0
    #puts "(#{x0},#{y0}): Line: #{lines[y0].join}: char: #{lines[y0][x0]}"
    while lines[y0][x] =~ /\d/
      xb = x
      if x > 0
        x -= 1
      else
        break
      end
    end
    #puts "   XB: #{xb}"
    return nil if xb.nil?
    xe = x0
    x = x0 + 1
    #puts "    CHECKING XE = #{x}"
    while lines[y0][x] =~ /\d/
      xe = x
      if x < lines[y0].length - 1
        x += 1
      else
        break
      end
    end
    #puts "   XE: #{xe}"
    #lines[y0][xb..xe].join().to_i
    [y0, (xb..xe)]
  end
  def part_numbers_at(x0, y0)
    parts = []
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        x = x0 + dx
        next if x < 0 || x > lines.first.size - 1
        y = y0 + dy
        next if y < 0 || y > lines.size - 1
        next if x == x0 && y == y0
        parts << number_at(x, y)
      end
    end
    parts.compact.uniq
  end

  def all_gears
    gears = []
    (0...lines.size).each do |y|
      (0...lines.first.size).each do |x|
        if lines[y][x] == '*'
          subparts = part_numbers_at(x,y)
          if subparts.size == 2
            p1= subparts.first
            p2= subparts.last
            p1_num = lines[p1.first][p1.last].join.to_i
            p2_num = lines[p2.first][p2.last].join.to_i
            gears << Gear.new(p1_num, p2_num)
          end
        end
      end
    end
    gears
  end

  def all_parts
    parts = []
    (0...lines.size).each do |y|
      (0...lines.first.size).each do |x|
        if lines[y][x] !~ /[\d\.]/ 
          subparts = part_numbers_at(x,y)
          parts.concat subparts
          parts.uniq!
        end
      end
    end
    parts
  end

end

def parse_schematic
  schematic = Schematic.new
  ARGV.replace(SAVE_ARGV)
  ARGF.each_line do |line|
    line.chomp!
    schematic.lines << line.split(//)
  end
  schematic
end

def part2
  s = parse_schematic
  s.all_gears.map(&:ratio).sum
end

def part1
  s = parse_schematic
  s.all_parts.map do |coords|
    y = coords.first
    xs = coords.last
    i = s.lines[y][xs].join.to_i
    i
  end.sum
end

puts "Part 1: #{part1}"
puts "Part 2: #{part2}"
