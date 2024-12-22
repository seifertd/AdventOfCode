require_relative '../../common/point'
require_relative '../../common/astar'
class Point
  def neighbors(grid, rows, cols, cheated, disallow_cheats, no_cheating)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject do |p|
      (p.x < 1 || p.y < 1 || p.y >= (rows - 1) || p.x >= (cols - 1)) ||
      ( grid[p.y][p.x] == WALL && (cheated || disallow_cheats.include?(p) || no_cheating))
    end
  end
end
Grid = Struct.new(:grid, :rows, :cols, :start, :finish, :disallow_cheats, :no_cheating, :path_length) do 
  WALL = :"#"
  FLOOR = :"."
  START = :S
  FINISH = :E
  def print(path = nil)
    mygrid = self.grid
    if !path.nil?
      mygrid = Marshal.load(Marshal.dump(mygrid))
      next_is_2 = false
      path.each do |p|
        next if p == self.start || p == self.finish
        if mygrid[p.y][p.x] == WALL
          mygrid[p.y][p.x] = :"1"
          next_is_2 = true
          next
        end
        if next_is_2
          mygrid[p.y][p.x] = :"2"
          next_is_2 = false
          next
        end
        mygrid[p.y][p.x] = :O
      end
    end
    puts mygrid.map{|r| r.map(&:to_s).join}.join("\n")
  end
  def parse
    self.grid = []
    self.rows = 0
    self.disallow_cheats = []
    self.no_cheating = true
    ARGF.each_line do |line|
      line.chomp!
      self.grid << line.split(//).map(&:to_sym)
      if self.cols.nil?
        self.cols = self.grid.last.size
      end
      if x = self.grid.last.index(START)
        self.start = Point.new(x, self.rows)
      end
      if x = self.grid.last.index(FINISH)
        self.finish = Point.new(x, self.rows)
      end
      self.rows += 1
    end
    self.path_length = Array.new(self.rows) { Array.new(cols, nil) }
  end
  def [](idx)
    self.grid[idx]
  end
  def g_score(from, to)
    1
  end
  def h_score(from, to, goal)
    from.taxi_dist(to)
  end
  def neighbors(of, path)
    cheated = path.any?{|p| self.grid[p.y][p.x] == WALL}
    of.neighbors(self.grid, self.rows, self.cols, cheated, self.disallow_cheats, self.no_cheating)
  end
end
class Solution
  def parse_grid
    grid = Grid.new
    grid.parse
    # Find no cheating path
    no_cheat_path = AStar.optimal_path(grid, grid.start, grid.finish)
    # Record length of no cheat path
    ncp_len = no_cheat_path.size - 1
    debug { "START: #{grid.start} FINISH: #{grid.finish} NON CHEATING PATH LEN: #{ncp_len}\n"}
    no_cheat_path.reverse.each.with_index do |p, idx|
      grid.path_length[p.y][p.x] = idx
    end
    [grid, ncp_len, no_cheat_path]
  end
  def part1
    grid, ncp_len, no_cheat_path = parse_grid
    cheat_points = {}
    no_cheat_path.each.with_index do |p, idx|
      [:<, :>, :v, :^].each do |dir|
        chk_pt = p.move(dir)
        dist_so_far = idx
        if chk_pt.x > 0 && chk_pt.y > 0 && chk_pt.x < (grid.cols-1) && chk_pt.y < (grid.rows-1) &&
          grid.grid[chk_pt.y][chk_pt.x] == WALL
          next_pt = chk_pt.move(dir)
          d2 = grid.path_length[next_pt.y][next_pt.x]
          cheat_dist = nil
          if !d2.nil?
            cheat_dist = dist_so_far + 2 + d2
          end
          if [FLOOR, FINISH].include?(grid.grid[next_pt.y][next_pt.x]) && cheat_dist
            old_dist = cheat_points[chk_pt]
            if cheat_dist < ncp_len && (old_dist.nil? || old_dist > cheat_dist)
              cheat_points[chk_pt] = cheat_dist
            end
          end
        end
      end
    end
    cheat_path_len_diffs = []
    cheat_points.each do |p, dist|
      cheat_path_len_diffs << (ncp_len - dist)
    end
    count = 0
    cheat_path_len_diffs.sort.group_by(&:itself).each do |val, values|
      debug { "There are #{values.size} cheat(s) that save #{val} picoseconds.\n"}
      count += values.size if val >= 100
    end
    count
  end
  def part2
    grid, ncp_len, no_cheat_path = parse_grid
    cheat_diffs = Hash.new{|h,k| h[k] = 0}
    cheat_points = {}
    max_cheat_dist = 20
    min_cheat_savings = (ENV['MIN_CHEAT_SAVINGS'] || 100).to_i
    no_cheat_path.each.with_index do |p, dist_so_far|
      check_pts = p.within_taxi(max_cheat_dist, grid.rows, grid.cols) { |nx, ny| [FINISH, FLOOR].include?(grid[ny][nx])}
      #debug { "DIST SO FAR: #{dist_so_far} P: #{p} check_pts: #{check_pts.size}\n" }
      check_pts.each do |cp|
        next if cp == p
        key = [p, cp]
        raise "Got duplicate cheat point: #{key.inspect}" if cheat_points.include?(key)
        dist_remaining = grid.path_length[cp.y][cp.x]
        raise "Got cheat point #{cp} not on no cheat path for path point #{p}" if dist_remaining.nil?
        cheat_dist = cp.taxi_dist(p)
        raise "Got cheat dist #{cheat_dist} between cheat point #{cp} and path point #{p}" if cheat_dist > max_cheat_dist
        new_path_len = (dist_so_far + cheat_dist + dist_remaining)
        if new_path_len < ncp_len
          cheat_diff = ncp_len - new_path_len
          #debug { "   - #{cp}: diff: #{cheat_diff} cheat: #{cheat_dist} remaining: #{dist_remaining} new: #{new_path_len} ncp: #{ncp_len}\n"}
          if cheat_diff >= min_cheat_savings
            cheat_points[key] = cheat_diff
            cheat_diffs[cheat_diff] += 1
          end
        end
      end
    end
    debug { "There were #{cheat_points.size} unique cheats\n"}
    total = 0
    cheat_diffs.keys.sort.each do |diff|
      count = cheat_diffs[diff]
      debug { "There are #{count} cheat(s) that save #{diff} picoseconds.\n"}
      total += count
    end
    total
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug
    print(yield) if ENV['DEBUG']
  end
end

if __FILE__ == $0
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    solution = Solution.new
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    solution = Solution.new
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
