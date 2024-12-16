require_relative "../../common/point"
require_relative "../../common/astar"

class Solution
  WALL = :"#"
  FLOOR = :"."
  GOAL =:E
  START = :S 
  DIRS = [:>, :v, :<, :^]
  class Map
    attr_accessor :rows, :cols, :grid, :start, :goal
    def to_s
      "Map[rows=#{rows},cols=#{cols},start=#{start},goal=#{goal}]"
    end
    def g_score(from, to)
      #print "GSCORE FROM: #{from} to #{to}"
      turns = (to.z - from.z).abs
      turns = 1 if turns == 3
      score = turns * 1000 + (from.x - to.x).abs + (from.y - to.y).abs
      #puts " #{score}"
      score
    end
    def h_score(from, to, goal)
      1000 + (goal.x - to.x).abs + (goal.y - to.y).abs
    end
    def neighbors(to, path)
      [
        Point.new(to.x - 1, to.y, 2),
        Point.new(to.x + 1, to.y, 0),
        Point.new(to.x, to.y - 1, 1),
        Point.new(to.x, to.y + 1, 3)
      ].reject {|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols || grid[p.y][p.x] == WALL }
    end
    def draw(path)
      mygrid = Marshal.load(Marshal.dump(grid))
      path.each {|p| mygrid[p.y][p.x] = '*'}
      puts mygrid.map{|l| l.join}.join("\n")
    end
    def cost(path)
      curr = path[0]
      idx = 1
      cost = 0
      debug = !ENV['DEBUG'].nil?
      while idx < path.size
        next_step = path[idx]
        #print "MOVE: #{curr} -> #{next_step}"
        turns = (next_step.z - curr.z).abs
        turns = 1 if turns == 3
        cost += turns * 1000
        cost += ((next_step.x - curr.x).abs + (next_step.y - curr.y).abs)
        #print " COST: #{cost}\n" if debug
        curr = next_step
        idx += 1
      end
      cost
    end
  end
  def parse_grid
    map = Map.new
    map.rows = map.cols = 0
    map.start = Point.new(0,0,0)
    map.goal = Point.new(0,0,0)
    map.grid = []
    input do |line|
      map.grid << line.split(//).map(&:to_sym)
      if idx = map.grid.last.index(START)
        map.start.x = idx
        map.start.y = map.grid.size - 1
      end
      if idx = map.grid.last.index(GOAL)
        map.goal.x = idx
        map.goal.y = map.grid.size - 1
      end
    end
    map.rows = map.grid.size
    map.cols = map.grid[0].size
    map
  end
  def part1
    map = parse_grid
    debug "#{map}\n"
    best_path = AStar.optimal_path(map, map.start, map.goal)
    map.draw(best_path) if ENV["DEBUG"]
    map.cost(best_path)
  end
  def part2
    map = parse_grid
    debug "#{map}\n"
    paths = AStar.optimal_path(map, map.start, map.goal, true)
    debug "Found #{paths.size} optimum paths\n"
    all_steps = paths.flatten.map{|p| Point.new(p.x, p.y)}.uniq
    debug "Containing #{all_steps.size} unique steps\n"
    map.draw(all_steps) if ENV["DEBUG"]
    all_steps.count
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
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
