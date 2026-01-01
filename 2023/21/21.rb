require '../../common/point'
class Point
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ]
  end
end
class Solution
  def parse
    @rocks = Hash.new{|h,k| h[k] = Hash.new{|h1,k1| h1[k1] = false}}
    @plots = Set.new
    @parity = Hash.new{|h,k| h[k] = Hash.new{|h1,k1| h1[k1] = nil}}
    @start = nil
    @rows = -1
    input do |line|
      @rows += 1
      @cols ||= line.size
      line.split(//).each.with_index do |c, idx|
        if c == '#'
          @rocks[idx][@rows] = true
        elsif c == 'S'
          @start = Point.new(idx, @rows)
        end
      end
    end
    @rows += 1
  end
  def print_grid(plots = true)
    viewport = [0, @rows - 1, 0, @cols - 1]
    if ENV['VIEWPORT']
      vp_size = ENV['VIEWPORT'].to_i
      viewport[0] = @start.y - vp_size
      viewport[1] = @start.y + vp_size
      viewport[2] = @start.x - vp_size
      viewport[3] = @start.x + vp_size
    end
    grid = Hash.new{|h1,row| h1[row] = Hash.new {|h2,col| h2[col] = '.'}}
    #@rocks.each { |r| grid[r.y][r.x] = '#' }
    if plots
      @plots.each { |p| grid[p.y][p.x] = 'O' }
      grid[@start.y][@start.x] = @plots.include?(@start) ? '*' : 'S'
    else
      @parity.each do |col, h|
        h.each do |row, parity|
          grid[row][col] = parity.even? ? 'E' : 'O'
        end
      end
    end
    viewport[0].upto(viewport[1]) do |row|
      print "%03d: " % row
      viewport[2].upto(viewport[3]) do |col|
        print '|' if col % @cols == 0
        if @rocks[col % @cols][row % @rows]
          print '#'
        else
          print "#{grid[row][col]}"
        end
      end
      puts
      puts "     " + '-' * (viewport[3] - viewport[2] + (viewport[3] - viewport[2])/@cols + 2) if row % @rows == (@rows - 1)
    end
  end
  def step(step)
    points = if @plots.empty?
               [@start]
             else
               @plots.to_a
             end
    @plots.clear
    points.each do |p|
      if p.x >= 0 && p.x < @cols && p.y >= 0 && p.y < @rows
        @parity[p.x][p.y] ||= step
      end
      @plots.merge p.neighbors(@rows, @cols).reject{|p| @rocks[p.x % @cols][p.y % @rows] }
    end
  end
  def part1
    parse
    steps = (ENV['STEPS'] || 6).to_i
    steps.times do |i|
      debug {
        #puts "\033[2J\033[1;1H"
        print_grid
        puts "STEPS: #{i} PLOTS: #{@plots.size}"
        $stdin.gets("\n")
        ""
      }
      step(i)
    end
    debug {
      #puts "\033[2J\033[1;1H"
      print_grid
      puts "STEPS:]#{steps} PLOTS: #{@plots.size}"
      ""
    }
    @plots.size
  end
  def num_rocks
    @rocks.values.map(&:values).flatten.count
  end
  def num_visited
    @parity.values.map(&:values).flatten.count
  end
  def part2
    parse
    grid_size = @rows * @cols
    nr = num_rocks
    to_visit = grid_size - nr
    debug { "GRID SIZE: #{grid_size}\n" }
    debug { "NUM ROCKS: #{nr}\n" }
    debug { "NUM VISITED: #{num_visited}\n" }
    debug { "TO VISIT: #{to_visit}\n" }
    steps = 0
    last_visited = num_visited
    while num_visited < to_visit
      step(steps)
      steps += 1
      if steps % 100 == 0
        debug { "STEPS: #{steps} NUM VISITED: #{num_visited}\n" }
      end
      break if num_visited == last_visited
      last_visited = num_visited
    end
    debug { "NUM VISITED: #{num_visited}\n" }
    debug { "STEPS: #{steps}\n" }
    print_grid(false)
    cd = @cols / 2
    debug { "CORNER DIST: #{cd}\n" }
    ef = @parity.values.map(&:values).flatten.count{|v| v.odd? }
    ec = @parity.values.map(&:values).flatten.count{|v| v > cd && v.odd? }
    of = @parity.values.map(&:values).flatten.count{|v| v.even? }
    oc = @parity.values.map(&:values).flatten.count{|v| v > cd && v.even? }
    debug { "EF: #{ef}\n" }
    debug { "EC: #{ec}\n" }
    debug { "OF: #{of}\n" }
    debug { "OC: #{oc}\n" }
    n = (26501365 - (@rows / 2)) / @rows
    debug { "N: #{n}\n" }
    ((n+1)*(n+1)) * of + (n*n) * ef - (n+1) * oc + n * ec
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
