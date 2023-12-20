require 'set'

Platform = Struct.new(:rows, :cols, :grid) do
  def initialize(rows = nil, cols = nil, grid = nil)
    self.rows = rows || 0
    self.cols = cols || 0
    self.grid = grid || []
  end

  def parse_line(line)
    self.grid << line.split(//)
    self.cols = self.grid.last.size
    self.rows += 1
  end

  def inspect
    str = "Rows: #{self.rows} Cols: #{self.cols}\n"
    str << self.grid.map(&:join).join("\n")
    str
  end

  def tilt(np = nil)
    np ||= Platform.new(self.rows, self.cols, Marshal.load(Marshal.dump(self.grid)))
    (1...np.rows).each do |y|
      (0...np.cols).each do |x|
        if np.grid[y][x] == 'O'
          y1 = y
          while y1 > 0 && np.grid[y1-1][x] == '.'
            np.grid[y1-1][x] = 'O'
            np.grid[y1][x] = '.'
            y1 -= 1
          end
        end
      end
    end
    np
  end

  def tilt_w
    (1...self.cols).each do |x|
      (0...self.rows).each do |y|
        if self.grid[y][x] == 'O'
          x1 = x
          while x1 > 0 && self.grid[y][x1-1] == '.'
            self.grid[y][x1-1] = 'O'
            self.grid[y][x1] = '.'
            x1 -= 1
          end
        end
      end
    end
  end

  def tilt_e
    (self.cols-2).downto(0) do |x|
      (0...self.rows).each do |y|
        if self.grid[y][x] == 'O'
          x1 = x
          while x1 < self.cols-1 && self.grid[y][x1+1] == '.'
            self.grid[y][x1+1] = 'O'
            self.grid[y][x1] = '.'
            x1 += 1
          end
        end
      end
    end
  end

  def tilt_s
    (self.rows-2).downto(0) do |y|
      (0...self.cols).each do |x|
        if self.grid[y][x] == 'O'
          y1 = y
          while y1 < self.rows-1 && self.grid[y1+1][x] == '.'
            self.grid[y1+1][x] = 'O'
            self.grid[y1][x] = '.'
            y1 += 1
          end
        end
      end
    end
  end

  def tilt_n
    tilt(self)
  end

  def cycle
    self.tilt_n
    self.tilt_w
    self.tilt_s
    self.tilt_e
  end

  def load
    (0...self.rows).map do |y|
      self.grid[y].count {|c| c == 'O'} * (self.rows - y)
    end.sum
  end
end

def parse_platform
  platform = Platform.new
  ARGF.each_line do |line|
    line.chomp!
    platform.parse_line(line)
  end
  platform
end

platform = parse_platform

DEBUG = false

def part1(platform)
  puts platform.inspect if DEBUG
  tilted = platform.tilt
  puts tilted.inspect if DEBUG
  tilted.load
end

def part2(platform)
  copy = Marshal.load(Marshal.dump(platform)) 
  hashes = {}
  puts "LOAD: #{platform.load} HASH: #{platform.grid.hash}\n#{platform.inspect}" if DEBUG
  idx = 0
  hash = platform.grid.hash
  hashes[hash] = idx
  while true
    idx += 1
    platform.cycle
    hash = platform.grid.hash
    puts "LOAD: #{platform.load} HASH: #{hash}\n#{platform.inspect}" if DEBUG
    if hashes.has_key?(hash)
      puts "Found cycle at index #{idx}" if DEBUG
      break
    end
    hashes[hash] = idx
  end
  prev_idx = hashes[hash]
  cycle_len = idx - prev_idx
  start_cycles = prev_idx
  r = (1_000_000_000 - start_cycles) % cycle_len
  puts "idx: #{idx} prev_idx: #{prev_idx} cycle_len: #{cycle_len} start_cycles: #{start_cycles} Remainder: #{r}" if DEBUG
  (start_cycles + r).times { copy.cycle }
  puts "LOAD: #{copy.load}" if DEBUG
  copy.load
end

puts "Part 1: #{part1(platform)}"
puts "Part 2: #{part2(platform)}"
