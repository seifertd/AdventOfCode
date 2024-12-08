require_relative '../../common/point'
require 'set'

class Solution
  def parse_grid
    @grid = []
    @guard = Point.new
    @guard_dir = :n
    y = 0
    input do |line|
      @grid << line.split(//)
      @grid.last.each.with_index do |c, x|
        if c == '^'
          @guard.x = x
          @guard.y = y
        end
      end
      y += 1
    end
  end
  def ngc(guard, dir, grid = @grid)
    ngp = guard.move(dir)
    #debug "GUARD NOW: #{@guard.inspect} DIR: #{@guard_dir.inspect} NEXT: #{ngp.inspect}\n"
    if ngp.y >= 0 && ngp.y < grid.size && ngp.x >= 0 && ngp.x < grid[0].size
      grid[ngp.y][ngp.x]
    else
      nil
    end
  end
  def print_grid(grid)
    grid.each do |row|
      puts row.join
    end
  end
  def walk_guard(guard, guard_dir, grid = @grid)
    visited = [Point.new(guard.x, guard.y, guard_dir)]
    loop do
      c = ngc(guard, guard_dir, grid)
      if ['.', '^'].include?(c)
        guard = guard.move(guard_dir)
        p = Point.new(guard.x, guard.y, guard_dir)
        if visited.include?(p)
          debug "LOOP: VISITED: #{visited.inspect} POINT: #{p.inspect}\n"
          return :loop
        else
          visited << p
        end
      elsif c == '#'
        guard_dir = case guard_dir
          when :n
            :e
          when :e
            :s
          when :s
            :w
          when :w
            :n
        end
      else
        p = Point.new(guard.x, guard.y, guard_dir)
        if !visited.include?(p)
          visited << p
        end
        debug "EXITING AT #{guard.inspect}\n"
        return visited
      end
    end
  end
  def part1
    parse_grid
    visited = walk_guard(@guard.dup, @guard_dir)
    if ENV['DEBUG']
      visited.each do |p|
        @grid[p.y][p.x] = 'X'
      end
      @grid[@guard.y][@guard.x] = '*'
      print_grid(@grid)
    end
    visited.map{|p| Point.new(p.x, p.y)}.uniq.size
  end
  def turn(guard_dir)
    case guard_dir
      when :n
        :e
      when :e
        :s
      when :s
        :w
      when :w
        :n
    end
  end
  def part2
    blocks = []
    parse_grid
    guard = @guard.dup
    original_grid = @grid.dup
    visited = walk_guard(guard, @guard_dir)
    # iterate over path and place block ('#') in front of each block
    visited.each.with_index do |p, count|
      if ENV['DEBUG']
        @grid = original_grid.dup
      end
      guard = @guard.dup
      next_p = p.move(p.z)
      next if next_p.y < 0 || next_p.x < 0 || next_p.y >= @grid.size || next_p.x >= @grid[0].size
      next if blocks.include?(Point.new(next_p.x, next_p.y))
      next if @grid[next_p.y][next_p.x] == '#'
      if count % 100 == 0
        puts "#{count}/#{visited.size} complete"
      end
      debug "NEXT: #{next_p.inspect}\n"
      oldc = @grid[next_p.y][next_p.x]
      @grid[next_p.y][next_p.x] = '#'
      r = walk_guard(guard, @guard_dir, @grid)
      if r == :loop
        bp = Point.new(next_p.x, next_p.y)
        blocks << bp unless blocks.include?(bp)
      end
      if ENV['DEBUG'] && count == -1
        r.each {|p| @grid[p.y][p.x] = 'X'}
        @grid[next_p.y][next_p.x] = 'Q'
        @grid[@guard.y][@guard.x] = '^'
        print_grid(@grid)
        exit 42
      end
      @grid[next_p.y][next_p.x] = oldc
    end
    blocks.uniq.count
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
