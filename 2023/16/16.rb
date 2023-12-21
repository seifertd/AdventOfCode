require 'set'
DEBUG = ENV['DEBUG'] == 'true'

Point = Struct.new(:char, :beams) do
  def initialize(char)
    self.char = char
    self.beams = Set.new
  end
  def to_s
    self.char
  end
  def inspect
    "#{self.char} #{beams.inspect}"
  end
  def add_beam(dir)
    if !self.beams.include?(dir)
      self.beams << dir
      false
    else
      true
    end
  end
end
Cave = Struct.new(:cols, :rows, :grid) do
  def initialize
    self.cols = 0
    self.rows = 0
    self.grid = []
  end
  def parse_line(line)
    chars = line.split(//)
    self.cols = chars.size
    self.grid << chars.map do |c|
      Point.new(c)
    end
    self.rows += 1
  end
  def inspect
    str = "Cave: Rows=#{self.rows} Cols=#{self.cols}\n"
    str << self.grid.map(&:join).join("\n")
    str
  end
  def energized
    self.grid.map do |row|
      row.map{|p| p.beams.size > 0 ? '#' : '.'}.join
    end.join("\n")
  end
  def beamview
    self.grid.map do |row|
      row.map do |p|
        if ['\\', '/', '|', '-'].include?(p.char)
          p.char
        elsif p.beams.size == 0
          '.'
        elsif p.beams.size > 1
          p.beams.size.to_s
        elsif p.beams.first == :e
          '>'
        elsif p.beams.first == :w
          '<'
        elsif p.beams.first == :n
          '^'
        elsif p.beams.first == :s
          'v'
        else
          raise "INVALID BEAM STATE FOR P:#{p.inspect}"
        end
      end.join
    end.join("\n")
  end
  def count_energized
    self.grid.map do |row|
      row.count { |p| p.beams.size > 0}
    end.sum
  end
  def illuminate(start_beam = Beam.new(0, -1, :e))
    beams = [ start_beam ]
    dead_beams = []
    while beams.size > 0
      beam = beams.shift
      while beam.alive
        split = beam.move(self)
        if split
          beams << split
        end
      end
      dead_beams << beam
    end
    puts "Still #{beams.size} beams left" if DEBUG
  end
end
Beam = Struct.new(:y, :x, :dir, :alive) do
  def initialize(y, x, dir)
    self.y = y
    self.x = x
    self.dir = dir
    self.alive = true
  end
  def move(cave)
    split = nil
    if self.dir == :e
      self.x += 1
    elsif self.dir == :w
      self.x -= 1
    elsif self.dir == :n
      self.y -= 1
    else
      self.y += 1
    end
    if self.x < 0 || self.x >= cave.cols || self.y < 0 || self.y >= cave.rows
      self.alive = false
      puts "Beam left cave: #{self.inspect}" if DEBUG
    else
      point = cave.grid[self.y][self.x]
      retracing = point.add_beam(self.dir)
      if retracing
        self.alive = false
        puts "Beam is retracing a path, killing: #{self.inspect}" if DEBUG
      else
        if point.char == '|'
          if [:e, :w].include?(self.dir)
            self.dir = :s
            split = Beam.new(self.y, self.x, :n)
          end
        elsif point.char == '-'
          if [:n, :s].include?(self.dir)
            self.dir = :e
            split = Beam.new(self.y, self.x, :w)
          end
        elsif point.char == '\\'
          if self.dir == :e
            self.dir = :s
          elsif self.dir == :w
            self.dir = :n
          elsif self.dir == :n
            self.dir = :w
          elsif self.dir == :s
            self.dir = :e
          end
        elsif point.char == '/'
          if self.dir == :e
            self.dir = :n
          elsif self.dir == :w
            self.dir = :s
          elsif self.dir == :n
            self.dir = :e
          elsif self.dir == :s
            self.dir = :w
          end
        end
      end
    end
    split
  end
end

def parse_cave
  cave = Cave.new
  ARGF.each_line do |line|
    line.chomp!
    cave.parse_line(line)
  end
  cave
end

def part1(cave)
  puts cave.inspect if DEBUG
  cave.illuminate
  puts "Energized:" if DEBUG
  puts cave.energized if DEBUG
  puts "Beam View:" if DEBUG
  puts cave.beamview if DEBUG
  cave.count_energized
end

def part2(cave)
  start_points = []
  cave.rows.times do |y|
    start_points << [y, -1, :e]
    start_points << [y, cave.cols, :w]
  end
  cave.cols.times do |x|
    start_points << [-1, x, :s]
    start_points << [cave.rows, x, :n]
  end
  start_points.map do |y,x,dir|
    copy_cave = Marshal.load(Marshal.dump(cave))
    start_beam = Beam.new(y, x, dir)
    copy_cave.illuminate(start_beam.dup)
    copy_cave.count_energized
  end.max
end

cave1 = parse_cave
cave2 = Marshal.load(Marshal.dump(cave1))

puts "Part 1: #{part1(cave1)}"
puts "Part 2: #{part2(cave2)}"
