require_relative '../../common/point'
require_relative '../../common/astar'

class PointWithTrail < Point
  attr_accessor :trail
  def initialize(x, y, trail = nil)
    super(x, y)
    @trail = trail || []
  end
  def move(dir)
    np = super(dir)
    _move(dir, np)
  end

  def _move(dir, np)
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

class PointWithTrail2 < PointWithTrail
  def _move(dir, np)
    np_with_trail = PointWithTrail2.new(np.x, np.y, self.trail.dup)
    if self.trail.nil? || self.trail.empty? || dir != self.trail.first
      np_with_trail.trail = [dir, 1]
    else
      np_with_trail.trail[1] += 1
    end
    np_with_trail
  end

  def to_s
    "(#{x},#{y}):#{trail.inspect}"
  end
end

class CityBlock2 < CityBlock
  def initialize(rows, cols, grid)
    self.rows = rows
    self.cols = cols
    self.grid = grid
  end
  def neighbors(to, path)
    new_dirs = nil
    #puts "FINDING NEIGHBORS OF #{to}"
    if to.y == self.rows - 1 && to.x == self.cols - 2 && (to.trail.first != :e || to.trail.last < 3)
      new_dirs = []
    elsif to.y == self.rows - 2 && to.x == self.cols - 1 && (to.trail.first != :s || to.trail.last < 3)
      new_dirs = []
    elsif to.trail.nil? || to.trail.empty? || to.trail.last == 0
      new_dirs = [:n, :e, :s, :w]
    elsif to.trail.last < 4
      new_dirs = [to.trail.first]
    else
      new_dirs = if [:e, :w].include?(to.trail.first)
                   [:n, :s]
                 else
                   [:e, :w]
                 end
      if to.trail.last < 10
        new_dirs << to.trail.first
      end
    end
    #puts "NEIGHBORS ARE IN DIRS #{new_dirs.inspect}"
    new_dirs.map{|d| to.move(d)}.reject do |p|
      rej = p.x < 0 || p.y < 0 || p.x >= self.cols || p.y >= self.rows
      #puts "REJECTING #{p}" if rej
      rej
    end
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
  debug = ENV['DEBUG'].include?("part1")
  start = PointWithTrail.new(0,0)
  finish = PointWithTrail.new(cb.cols-1, cb.rows-1)
  puts "Start: #{start} Finish: #{finish}" if debug
  puts cb.inspect if debug
  best_path = AStar.optimal_path(cb, start, finish)
  puts "Best Path:" if debug
  puts best_path.inspect if debug
  puts cb.draw_with_path(best_path) if debug
  hl = cb.heat_loss(best_path)
  puts "Heat Loss: #{hl}" if debug
  hl
end

def part2(cb)
  debug = ENV['DEBUG'].include?("part2")
  cb = CityBlock2.new(cb.rows, cb.cols, cb.grid)
  start = PointWithTrail2.new(0,0)
  finish = PointWithTrail2.new(cb.cols-1, cb.rows-1)
  puts "Start: #{start} Finish: #{finish}" if debug
  puts cb.inspect if debug
  best_path = AStar.optimal_path(cb, start, finish)
  puts "Best Path:" if debug
  puts best_path.inspect if debug
  puts cb.draw_with_path(best_path) if debug
  hl = cb.heat_loss(best_path)
  puts "Heat Loss: #{hl}" if debug
  hl
end
cb = parse_city_block

puts "Part 1: #{part1(cb)}"
puts "Part 2: #{part2(cb)}"
