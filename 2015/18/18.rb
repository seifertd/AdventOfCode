class Solution
  def parse
    @grid = []
    input do |line|
      @grid << line.split(//)
    end
    @rows = @grid.size
    @cols = @grid[0].size
  end
  def gol_iterate
    live = []
    die = []
    @grid.each.with_index do |row, y|
      row.each.with_index do |c, x|
        ln = live_neighbors(x,y)
        if c == '#'
          if ln < 2 || ln > 3
            die << [x,y]
          end
        else
          if ln == 3
            live << [x,y]
          end
        end
      end
    end
    die.each do |x,y|
      @grid[y][x] = '.'
    end
    live.each do |x,y|
      @grid[y][x] = '#'
    end
  end
  def live_cells
    @grid.map { |r| r.count('#') }.sum
  end
  def live_neighbors(ox, oy)
    count = 0
    [oy-1, 0].max.upto([oy+1,@rows-1].min) do |y|
      [ox-1, 0].max.upto([ox+1,@cols-1].min) do |x|
        count += 1 if @grid[y][x] == '#' && !(x==ox && y==oy)
      end
    end
    count
  end
  def print_grid
    puts @grid.map{|r| r.join }.join("\n")
    puts
  end
  def part1
    parse
    generations = (ENV['GENERATIONS'] || 4).to_i
    debug { "ROWS: #{@rows} COLS: #{@cols} LIVE: #{live_cells} GENS: #{generations}\n" }
    generations.times { gol_iterate }
    live_cells
  end
  def part2
    parse
    generations = (ENV['GENERATIONS'] || 4).to_i
    debug { "ROWS: #{@rows} COLS: #{@cols} LIVE: #{live_cells} GENS: #{generations}\n" }
    turn_on_corners
    if ENV['SHOW_GRID']
      puts "INITIAL STATE:"
      print_grid
    end
    generations.times do |step|
      gol_iterate
      turn_on_corners
      if ENV['SHOW_GRID']
        puts "STEP: #{step+1} LIVE: #{live_cells}"
        print_grid
      end
    end
    # Turn the corners back on
    live_cells
  end
  def turn_on_corners
    @grid[0][0] = '#'
    @grid[0][@cols - 1] = '#'
    @grid[@rows - 1][0] = '#'
    @grid[@rows - 1][@cols - 1] = '#'
  end
  def input
    if block_given?
      ARGF.each_line do |line|
        line.chomp!
        yield(line)
      end
    else
      return to_enum(:input)
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
