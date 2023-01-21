require_relative "./advent_of_code"
require 'ruby-progressbar'

class Day17 < AdventOfCode
  attr_reader :rocks, :jets, :width, :rock_start,
              :rock, :bottom, :arena, :rock_pos
  attr_accessor :max_rock_count
  def initialize
    super(:max_rock_count)
    @max_rock_count ||= 11
    @width = 7
    @bottom = 3
    @highest_rock = 3
    # coordinate of lower left corner of the 4x4 rock
    # relative to highest rock
    @rock_start = Point.new(2, 3)
    @rock_pos = nil
    @rock = nil
    read_input do |line|
      @jets = Cycle.new(line.split(//))
    end
    init_arena
    @stopped = Marshal.load(Marshal.dump(@arena))
    @rocks = Cycle.new(
      [
        { width: 4, height: 1, rows_to_check: 1, pixels: [
          [1,1,1,1]
        ]},
        { width: 3, height: 3, rows_to_check: 2, pixels: [
          [0,1,0],
          [1,1,1],
          [0,1,0]
        ]},
        { width: 3, height: 3, rows_to_check: 1, pixels: [
          [1,1,1],
          [0,0,1],
          [0,0,1]
        ]},
        { width: 1, height: 4, rows_to_check: 1, pixels: [
          [1],
          [1],
          [1],
          [1]
        ]},
        { width: 2, height: 2, rows_to_check: 1, pixels: [
          [1,1],
          [1,1]
        ]}
      ]
    )
  end
  def init_arena
    @arena = []
    height = @bottom+1
    if @stopped
      height = [height, @stopped.size].min
    end
    height.times do
      @arena << ['.']*@width
    end
    puts "INIT ARENA, HEIGHT = #{height}, BOTTOM: #{@bottom}, @stopped: #{@stopped.inspect}"
  end
  def trim_stopped
    # find highest index of a rock in each column, then trim beyond that
    max_y = 0
    @width.times do |x|
      0.upto(@bottom) do |y|
        if @stopped[y][x] == '#'
          max_y = [max_y,y].max
          break
        end
        max_y = [max_y,y].max
      end
    end
    if max_y < @stopped.size - 1
      #puts "AFTER ROCK #{@rock_count}, TRIM AT #{max_y}, BOTTOM=#{@bottom}"
      #draw_arena
      (@stopped.size - max_y - 1).times { @stopped.pop }
      #draw_arena
      #exit
    end
  end
  def expand_arena
    # no-op if rock has stopped
    return if @rock.nil?
    # expand arena by rock height - 1 if rock y coord is too low
    expand_by = @rock[:height] - 1 - @rock_pos.y
    if expand_by > 0
      # rock y coord and @bottom increases by expand_by
      @rock_pos.y += expand_by
      @bottom += expand_by
      @highest_rock += expand_by
      expand_by.times { @stopped.unshift(['.'] * @width) }
      trim_stopped
    end
  end
  def draw_rock_in_arena
    if !@rock.nil?
      draw_rock(@arena, '@')
    end
  end
  def draw_rock_in_stopped
    draw_rock(@stopped, '#')
  end
  def draw_rock(grid, char)
    @rock[:height].times do |h|
      @rock[:width].times do |w|
        ay = @rock_pos.y - h
        ax = @rock_pos.x + w
        pixel = @rock[:pixels][h][w]
        if ay >= 0 && ay <= @bottom &&
           ax >= 0 && ax <= (@width-1) &&
           pixel == 1
          grid[ay][ax] = char
        end
      end
    end
  rescue Exception => e
    puts "ERROR: can't draw rock #{@rock_pos}: #{e}"
  end
  def rock_blocked_side(offset)
    @rock[:height].times do |h|
      @rock[:width].times do |w|
        if @rock[:pixels][h][w] == 1
          ay = @rock_pos.y - h
          ax = @rock_pos.x + w + offset
          return true if @stopped[ay][ax] == '#'
        end
      end
    end
    false
  rescue Exception => e
    puts "ERROR: #{e}"
    draw_arena
    exit
  end
  def blow_jet
    jet = @jets.next
    case jet
    when '<'
      #print "JET LEFT "
      if @rock_pos.x > 0 && !rock_blocked_side(-1)
        @rock_pos.x -= 1
      end
    when '>'
      #print "JET RIGHT "
      if (@rock_pos.x + @rock[:width]) < @width &&
          !rock_blocked_side(1)
        @rock_pos.x += 1
      end
    end
  end
  def rock_stopped?
    return true if @rock_pos.y >= @bottom
    # Check pixels against stopped rocks below
    @rock[:rows_to_check].times do |h|
      @rock[:width].times do |w|
        pixel = @rock[:pixels][h][w]
        ay = @rock_pos.y - h
        ax = @rock_pos.x + w
        srock = @stopped[ay+1][ax]
        return true if pixel == 1 && srock == '#'
      end
    end
    false
  end
  def fall_rock
    if rock_stopped?
      #print "STOP "
      draw_rock_in_stopped
      @rock = nil
      @rock_pos = nil
    else
      #print "FALL "
      @rock_pos.y += 1
    end
  end
  def draw_arena
    init_arena
    draw_rock_in_arena
    #puts "BOTTOM: #{@bottom} WIDTH: #{@width} ROCK_POS: #{@rock_pos}"
    #if @bottom > 10
    #  indexes = [(0..5).to_a,(@bottom-5..@bottom).to_a].flatten
    #else
    #  indexes = (0..@bottom).to_a
    #end
    @arena.each.with_index do |row, ay|
    #indexes.each.with_index do |ay, idx|
      #break if ay > @bottom
      #if ay - indexes[idx-1] > 1
      #  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      #end
      #row = @arena[ay]
      printf "%5d: |", ay
      row.each.with_index do |col, ax|
        if @stopped[ay][ax] == '#'
          print '#'
        else
          print col
        end
      end
      print "|"
      puts
    end
    puts "       +-------+"
    puts
  end
  def part1
    @rock_count = 0
    #@max_rock_count = 1_000_000_000_000
    #@max_rock_count = 2022
    #@max_rock_count = 100_000
    pb = ProgressBar.create(:total => @max_rock_count + 1, :title => "Rocks",
                            :format => "%t %f %W %a")
    while true
      if @rock.nil?
        break if @rock_count > @max_rock_count
        @rock = @rocks.next
        y = @highest_rock
        while y >= 0 && @stopped[y].any?('#')
          y -= 1
        end
        @highest_rock = y + 1 if y < @bottom
        @rock_pos = Point.new(@rock_start.x, y - @rock_start.y)
        expand_arena
        @rock_count += 1
        pb.increment
        puts "HIGHEST ROCK: #{@highest_rock}" if ENV['DEBUG'] == "Y"
        puts "ROCK #{@rock_count}" if ENV['DEBUG'] == "Y"
        draw_arena if ENV['DEBUG'] == "Y"
        #break if @rock_count == 11
      end
      #draw_arena
      blow_jet
      #draw_arena
      fall_rock
    end
    puts "BOTTOM: #{@bottom} HIGHEST: #{@highest_rock}" if ENV['DEBUG'] == "Y"
    puts "Part 1: Height of rock tower after #{@rock_count} rocks: #{@bottom - @highest_rock + 1}"
  end
end

if __FILE__ == $PROGRAM_NAME
  solution = Day17.new
  solution.run
end
