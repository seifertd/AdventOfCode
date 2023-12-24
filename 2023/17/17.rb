require_relative '../common/point'
require_relative '../common/astar'

class PointWithTrail < Point
  attr_reader :trail
  def initialize(x, y, trail = nil)
    super(x, y)
    @trail = trail || []
  end
  def move(dir)
    np = super(dir)
    np_with_trail = PointWithTrail.new(np.x, np.y, self.trail.dup)
    np_with_trail.trail << dir
    np_with_trail.trail.shift if np_with_trail.trail.size > 3
    np_with_trail
  end
  def eql?(o)
    self.x == o.x && self.y == o.y && self.trail == o.trail
  end
  def hash
    h = 7
    h = 31 * h + self.x
    h = 31 * h + self.y
    h = 31 * h + self.trail.hash
    h
  end
end

CityBlock = Struct.new(:rows, :cols, :grid) do
  def initialize
    self.rows = 0
    self.cols = 0
    self.grid = []
  end

  def inspect
    "CityBlock: rows=#{self.rows} cols=#{self.cols}\n#{self.grid.map(&:join).join("\n")}"
  end

  def add_line(line)
    self.grid << line.split(//).map(&:to_i)
    self.cols = self.grid.last.size
    self.rows += 1
  end

  def heat_loss(path)
    (path[1..-1] || []).map do |p|
      self.grid[p.y][p.x]
    end.sum
  end

  def draw_with_path(path)
    tgrid = Marshal.load(Marshal.dump(self.grid))
    (path[1..-1] || []).each.with_index do |p, idx|
      dir = p.direction_from(path[idx])
      char = if dir == :e
               '>'
             elsif dir == :w
               '<'
             elsif dir == :n
               '^'
             else
               'v'
             end
      tgrid[p.y][p.x] = char
    end
    tgrid.map(&:join).join("\n")
  end

  def neighbors(to, path)
    new_dirs = [:n, :e, :s, :w]
    if path.size > 1
      from = path[-2]
      dir = from.direction_from(to)
      #puts "DIRECTION FROM #{to} back to #{from} is #{dir}, removing"
      new_dirs.delete(dir)
    end
    if path.size >= 4
      cur_from = -2
      allow_dir = false
      2.times do
        new_from = path[cur_from - 1]
        if new_from.direction_from(from) != dir
          allow_dir = true
          break
        end
        cur_from -= 1
        from = new_from
      end
      if !allow_dir
        # If we have been travelling in the same dir for 3 steps, disallow
        # continuing in that direction
        #puts "MOVED FROM #{dir} 3 TIMES, REMOVING THE OPPOSITE DIR"
        new_dirs.delete(path[-2].direction_to(to))
      end
    end
    #puts "NEIGHBORS ARE IN DIRS #{new_dirs.inspect}"
    new_dirs.map{|d| to.move(d)}.reject do |p|
      rej = p.x < 0 || p.y < 0 || p.x >= self.cols || p.y >= self.rows
      #puts "REJECTING #{p}" if rej
      rej
    end
  end

  def g_score(from, to)
    self.grid[to.y][to.x]
  end

  def h_score(from, to, goal)
    to.taxi_dist(goal)
  end
end

def parse_city_block
  cb = CityBlock.new
  ARGF.each_line do |line|
    cb.add_line(line.chomp)
  end
  cb
end

def part1(cb)
  start = PointWithTrail.new(0,0)
  finish = PointWithTrail.new(cb.cols-1, cb.rows-1)
  #puts "Start: #{start} Finish: #{finish}"
  #puts cb.inspect
  best_path = AStar.optimal_path(cb, start, finish)
  #puts "Best Path:"
  #puts best_path.inspect
  #puts cb.draw_with_path(best_path)
  hl = cb.heat_loss(best_path)
  #puts "Heat Loss: #{hl}"
  hl
end

cb = parse_city_block

puts "Part 1: #{part1(cb)}"
