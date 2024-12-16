require_relative "../../common/point"

class Solution
  BOT = :"@"
  BOX = :O
  BOX_LEFT = :"["
  BOX_RIGHT = :"]"
  WALL = :"#"
  FLOOR = :"."
  LEFT = :<
  RIGHT = :>
  UP = :^
  DOWN = :v
  def count_grid(grid, rows, cols)
    counts = Hash.new{|h,k| h[k] = 0}
    rows.times {|y| cols.times {|x| counts[grid[y][x]] += 1}}
    counts
  end
  def parse_grid(doubling = false)
    grid = []
    bot = nil
    rows = 0
    cols = nil
    moves = []
    num_boxes = 0
    reading_moves = false
    input do |line|
      if line == ""
        reading_moves = true
        next
      end
      if reading_moves
        moves.concat(line.split(//).map(&:to_sym))
        next
      end
      newrow = line.split(//).map(&:to_sym)
      num_boxes += newrow.count(BOX)
      if doubling
        newrow = newrow.zip(newrow).flatten
        newrow.each.with_index do |sym, idx|
          if sym == BOT
    counts = 
            newrow[idx+1] = FLOOR
          elsif sym == BOX
            newrow[idx] = BOX_LEFT
            newrow[idx+1] = BOX_RIGHT
          end
        end
      end
      grid << newrow
      if bot_x = grid.last.index(BOT)
        bot = Point.new(bot_x, rows)
      end
      rows += 1
      cols ||= grid.last.size
    end
    debug "PARSED: #{num_boxes} boxes\n"
    [grid, rows, cols, bot, moves]
  end
  def move_bot(grid, rows, cols, bot, move)
    move_obj(grid, rows, cols, bot, BOT, move)
  end
  def print_grid(grid, rows, cols)
    puts grid.map{|row| row.join }.join("\n")
  end
  def box_group(grid, rows, cols, box, sym, dir)
    grp = []
    queue = [box]
    ydiff = dir == :^ ? -1 : 1
    if sym == BOX_RIGHT
      queue << Point.new(box.x - 1, box.y)
    else
      queue << Point.new(box.x + 1, box.y)
    end
    while !queue.empty?
      b = queue.shift
      grp << b
      if [BOX_RIGHT, BOX_LEFT].include?(grid[b.y+ydiff][b.x])
        bsym = grid[b.y+ydiff][b.x]
        np = Point.new(b.x, b.y+ydiff)
        queue << np unless queue.include?(np)
        if bsym == BOX_RIGHT
          npp = Point.new(np.x - 1, np.y)
          queue << npp unless queue.include?(npp)
        else
          npp = Point.new(np.x + 1, np.y)
          queue << npp unless queue.include?(npp)
        end
      end
    end
    grp.group_by{|p| p.y}
  end
  def move_obj(grid, rows, cols, obj, sym, move)
    next_pos = obj.move(move)
    next_obj = grid[next_pos.y][next_pos.x]
    case next_obj
    when FLOOR
      grid[obj.y][obj.x] = FLOOR
      obj.x = next_pos.x
      obj.y = next_pos.y
      grid[obj.y][obj.x] = sym
      true
    when WALL
      # do nothing
      false
    when BOX, BOX_LEFT, BOX_RIGHT
      #debug("MOVING IN DIR #{move.inspect}, NEXT CHAR IS A BOX: #{next_obj.inspect}\n")
      if next_obj == BOX || [:<, :>].include?(move)
        if move_obj(grid, rows, cols, next_pos.dup, next_obj, move)
          grid[obj.y][obj.x] = FLOOR
          obj.x = next_pos.x
          obj.y = next_pos.y
          grid[obj.y][obj.x] = sym
          true
        else
          false
        end
      else
        bgrp = box_group(grid, rows, cols, next_pos, next_obj, move)
        #debug "MOVING A BOX GROUP: #{bgrp.inspect}\n"
        row_idxs = bgrp.keys.sort
        row_idxs.reverse! if move == :v
        if bgrp.values.flatten.any? do |p|
            if move == :^
              ![FLOOR, BOX_LEFT, BOX_RIGHT].include?(grid[p.y-1][p.x])
            else
              ![FLOOR, BOX_LEFT, BOX_RIGHT].include?(grid[p.y+1][p.x])
            end
          end
          #debug "CAN'T MOVE BOX GROUP IN DIR #{move.inspect}, blocked by non floor\n"
          false
        else
          row_idxs.each do |ridx|
            bgrp[ridx].each do |p|
              np = p.move(move)
              #debug "MOVING POINT #{p} to #{np}\n"
              grid[np.y][np.x] = grid[p.y][p.x]
              grid[p.y][p.x] = FLOOR
            end
          end
          grid[obj.y][obj.x] = FLOOR
          obj.x = next_pos.x
          obj.y = next_pos.y
          grid[obj.y][obj.x] = sym
          true
        end
      end
    end
  end
  def gps_coords(grid, rows, cols)
    gps_sum = 0
    rows.times do |y|
      cols.times do |x|
        if [BOX, BOX_LEFT].include?(grid[y][x])
          gps_sum += 100 * y + x
        end
      end
    end
    gps_sum
  end
  def part1
    grid, rows, cols, bot, moves = parse_grid
    debug "BOT: #{bot} ROWS: #{rows} COLS: #{cols} MOVES: #{moves.inspect}\n"
    print_grid(grid, rows, cols) if ENV["DEBUG"]
    moves.each do |move|
      case move
      when LEFT, RIGHT, UP, DOWN
        move_bot(grid, rows, cols, bot, move)
      else
        raise "Found illegal move: #{move.inspect}"
      end
      if ENV['DEBUG']
        puts "Move #{move.inspect} :"
        print_grid(grid, rows, cols)
      end
    end
    gps_coords(grid, rows, cols)
  end
  def part2
    if ENV["DEBUG"]
      print "\033[2J"
      print "\033[H"
    end
    grid, rows, cols, bot, moves = parse_grid(true)
    start_counts = count_grid(grid, rows, cols)
    #debug "BOT: #{bot} ROWS: #{rows} COLS: #{cols} MOVES: #{moves.inspect}\n"
    #print_grid(grid, rows, cols) if ENV["DEBUG"]
    if ENV["DEBUG"]
      print "\033[2J"
      print "\033[H"
      print_grid(grid, rows, cols)
    end
    moves.each.with_index do |move, idx|
      move_bot(grid, rows, cols, bot, move)
      if ENV['DEBUG']
        print "\033[H"
        print_grid(grid, rows, cols)
        puts "MOVE #{idx+1}/#{moves.size} GPS_SUM: #{gps_coords(grid,rows,cols)} COUNTS: #{count_grid(grid, rows, cols).inspect}"
        sleep 0.1
      end
      #counts = count_grid(grid, rows, cols)
      #counts.each do |k, c|
      #  if start_counts[k] != c
      #    print_grid(grid, rows, cols)
      #    puts "FUCKED SOMETHING UP ON MOVE #{idx+1}"
      #    puts "ORIGINAL COUNTS: #{start_counts.inspect}"
      #    puts "CURRENT COUNTS: #{counts.inspect}"
      #    exit 42
      #  end
      #end

    end
    if ENV["DEBUG"]
      print "\033[H"
      print_grid(grid, rows, cols)
      puts
    end
    debug "START COUNTS: #{start_counts.inspect}\n"
    gps_coords(grid, rows, cols)
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
