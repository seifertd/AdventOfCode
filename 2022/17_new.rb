require_relative "./advent_of_code"
require 'ruby-progressbar'

class Arena
  attr_reader :top, :bottom, :size
  def initialize(size, capacity = 128)
    @top = 0
    @size = size
    @bottom = size - 1
    @capacity = capacity
    @width = 7
    @rows = [0] * @capacity
  end
  def reset(top, bottom)
    @top = top
    @bottom = bottom
    if top > bottom
      bottom += @capacity
      @size = bottom - @top + 1
    end
  end
  def hash
    result = @size.hash
    @size.times do |idx|
      row = @rows[(@top + idx) % @capacity]
      result = 31 * result + row.hash
    end
    result
  end
  def size
    @size
  end
  def [](index)
    throw "Index #{index} out of bounds" if index > @size - 1 || index < 0
    @rows[(@top + index) % @capacity]
  end
  def []=(index, value)
    throw "Index #{index} out of bounds" if index > @size - 1 || index < 0
    @rows[(@top + index) % @capacity] = value
  end
  def get_char_for(ay, ax, rock = nil, rock_pos = nil)
    if rock.nil? || rock_pos.nil?
      return '.'
    end
    if ay >= rock_pos.y - rock[:height] + 1 && ay <= rock_pos.y
      #print "get_char(#{ax},#{ay}), rock: #{rock.inspect}(#{rock_pos})"
      ph = rock_pos.y - ay
      pixels = rock[:pixels][ph]
      #print " ph: #{ph} pixels: #{pixels}"
      row = @rows[ay]
      lshift = (6-rock_pos.x) - (rock[:width] - 1)
      #print " lshift: #{lshift}"
      row = row | (pixels << lshift)
      #printf " %07b \n", row
      if (row & (1 << (6-ax))) > 0
        return '@'
      end
    end
    '.'
  end
  def expand_top(size)
    if @size + size > @capacity
      throw "Can't expand by #{size}, not enough capacity"
    end
    newtop = (@top - size) % @capacity
    if newtop > @top
      (0..@top-1).each { |i| @rows[i] = 0 }
      (newtop..@capacity-1).each { |i| @rows[i] = 0 }
    else
      (newtop..@top-1).each { |i| @rows[i] = 0 }
    end
    @top = newtop
    @size += size
  end
  def chop_bottom(size)
    if @size - size <= 0
      throw "Can't chop by #{size}, arena not big enough"
    end
    newbottom = (@bottom - size) % @capacity
    if newbottom > @bottom
      (0..@bottom-1).each {|i| @rows[i] = 0 }
      (newbottom..@capacity-1).each {|i| @rows[i] = 0}
    else
      (newbottom..@bottom-1).each {|i| @rows[i] = 0}
    end
    @bottom = newbottom
    @size -= size
  end
  def draw(rock = nil)
    puts "DRAW: TOP=#{@top} BOTTOM: #{@bottom} SIZE: #{@size}"
    @size.times do |idx|
      ay = (@top + idx) % @capacity
      row = @rows[ay]
      printf "%5d: |", idx
      @width.times do |ax|
        if (row & (1 << (6-ax))) > 0
          print '#'
        else
          print get_char_for(ay, ax)
        end
      end
      print "|"
      puts
    end
    puts "       +-------+"
    puts
  end
  def self.test
    a = Arena.new(3)
    a.draw
    puts "HASH: #{a.hash}"
    puts "Equivalent?"
    b = Arena.new(3)
    b.reset(127,1)
    b.draw
    puts "HASH: #{b.hash}"
    a.expand_top(4)
    a[3] = 25
    a.draw
    a.reset(127, 5)
    a.draw
    a[0] = 21
    a[5] = 9
    a.draw
    #a[7] = 21
    exit 42
  end
end

#Arena.test
#exit 42


class Day17 < AdventOfCode
  attr_reader :rocks, :jets, :width, :rock_start,
              :rock, :bottom, :arena, :rock_pos
  attr_accessor :max_rock_count
  EMPTY = 0
  ROCK = 1
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
    @hashes = {}
    read_input do |line|
      @jets = Cycle.new(line.split(//))
    end
    init_arena
    draw_arena
    @rocks = Cycle.new(
      [
        { index: 0, width: 4, height: 1, rows_to_check: 1, pixels: [15] },
        { index: 1, width: 3, height: 3, rows_to_check: 2, pixels: [2,7,2] },
        { index: 2, width: 3, height: 3, rows_to_check: 1, pixels: [7,1,1] },
        { index: 3, width: 1, height: 4, rows_to_check: 1, pixels: [1,1,1,1] },
        { index: 4, width: 2, height: 2, rows_to_check: 1, pixels: [3,3]}
      ]
    )
  end
  def init_arena
    @arena = []
    height = @bottom+1
    height.times do
      @arena << 0
    end
  end
  def cycle_check
    hash = @rock[:index].hash
    hash = 31 * hash + @jets.counter.hash
    (@rock_pos.y+1).upto(@bottom) do |ay|
      hash = 31 * hash + @arena[ay].hash
    end
    if @hashes.has_key?(hash)
      puts "CYCLE DETECTED AT #{@rock_count}, HEIGHT/COUNT/BOTTOM LAST: #{@hashes[hash].inspect} HEIGHT CURRENT: #{@highest_rock}"
      exit 42
    else
      puts "CYCLE CHECK: ROCK=#{rock[:index]} COUNT=#{@rock_count} HIGHEST=#{@highest_rock} BOTTOM: #{@bottom}"
      @hashes[hash] = [@highest_rock, @rock_count, @bottom]
    end
  end
  def trim_stopped
    # find highest index of a rock in each column, then trim beyond that
    max_y = 0
    rocks = 0
    @highest_rock.upto(@arena.size - 1) do |y|
      row = @arena[y]
      if row > 0  # There are some rocks here
        rocks = rocks | row # record columns with rocks
        max_y = [max_y,y].max # record index
      end
      break if rocks == 0b1111111 # we are done once we find a rock in each column
    end
    if max_y < @arena.size - 1
      (@arena.size - max_y - 1).times { @arena.pop }
    end
  end
  def expand_arena
    #puts "EXPAND ARENA, ROCK = #{@rock.inspect}, POS = #{@rock_pos.inspect} BOTTOM=#{@bottom} HIGHEST ROCK = #{@highest_rock} ARENA = #{@arena.inspect}"
    # no-op if rock has stopped
    return if @rock.nil?
    # expand arena by rock height - 1 if rock y coord is too low
    expand_by = @rock[:height] - 1 - @rock_pos.y
    #puts "    -> expand_by = #{expand_by}"
    if expand_by > 0
      # rock y coord and @bottom increases by expand_by
      @rock_pos.y += expand_by
      @bottom += expand_by
      @highest_rock += expand_by
      expand_by.times { @arena.unshift(0) }
    end
  end
  def draw_stopped_rock
    puts "STOPPING ROCK AT #{@rock_pos}" if ENV['DEBUG'] == 'Y'
    @rock[:height].times do |h|
      ay = @rock_pos.y - h
      ax = @rock_pos.x
      lshift = (6-ax) - (@rock[:width] - 1)
      pixels = (@rock[:pixels][h] << lshift ) & 0xff
      #printf "PIXELS OF STOPPED = %07b\n", pixels
      @arena[ay] |= pixels
    end
  rescue Exception => e
    puts "ERROR: can't draw rock #{@rock_pos}: #{e}"
  end
  def rock_blocked_side(ax)
    @rock[:height].times do |h|
      ay = @rock_pos.y - h
      return true if (@arena[ay] & (@rock[:pixels][h] << (6-ax-@rock[:width]+1))) > 0
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
      if @rock_pos.x > 0 && !rock_blocked_side(@rock_pos.x - 1)
        @rock_pos.x -= 1
      end
    when '>'
      #print "JET RIGHT "
      if (@rock_pos.x + @rock[:width]) < @width &&
          !rock_blocked_side(@rock_pos.x + 1)
        @rock_pos.x += 1
      end
    end
  end
  def rock_stopped?
    # did we hit the bottom ...
    #if @rock_pos.y == @arena.size - 1
    #  return true
    #end
    ay = ax = pixels = nil
    begin
      return true if @rock_pos.y >= @bottom
      # Check pixels against stopped rocks below
      @rock[:rows_to_check].times do |h|
        pixels = @rock[:pixels][h]
        ax = @rock_pos.x
        ay = @rock_pos.y - h + 1
        pixels = (pixels << (6 - ax - @rock[:width] + 1)) & 0xff
        #printf "ay=#{ay} arena[ay]=%07b pixels=%07b maxy=#{@arena.size} hitting? #{(@arena[ay] & pixels) > 0}\n", arena[ay], pixels
        if (@arena[ay] & pixels) > 0
          return true
        end
      end
      false
    rescue Exception => e
      printf "ay=#{ay} arena[ay]=%07b arena[ay-1]=%07b pixels=%07b rock=#{@rock_count}:#{@rock_pos} bottom=#{@bottom} max_y=#{@arena.size - 1}\n", @arena[ay] || 0, @arena[ay-1], pixels
      draw_arena
      throw e
    end
  end
  def fall_rock
    if rock_stopped?
      #print "STOP "
      draw_stopped_rock
      @rock = nil
      @rock_pos = nil
    else
      #print "FALL "
      @rock_pos.y += 1
    end
  end
  def get_char_for(ay, ax)
    if @rock.nil?
      return '.'
    end
    if ay >= @rock_pos.y - @rock[:height] + 1 && ay <= @rock_pos.y
      #print "get_char(#{ax},#{ay}), rock: #{@rock.inspect}(#{@rock_pos})"
      ph = @rock_pos.y - ay
      pixels = @rock[:pixels][ph]
      #print " ph: #{ph} pixels: #{pixels}"
      row = @arena[ay]
      lshift = (6-@rock_pos.x) - (@rock[:width] - 1)
      #print " lshift: #{lshift}"
      row = row | (pixels << lshift)
      #printf " %07b \n", row
      if (row & (1 << (6-ax))) > 0
        return '@'
      end
    end
    '.'
  end
  def draw_arena
    @arena.each.with_index do |row, ay|
      printf "%5d: |", ay
      @width.times do |ax|
        if (row & (1 << (6-ax))) > 0
          print '#'
        else
          print get_char_for(ay, ax)
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

    #draw_arena if ENV['DEBUG'] == 'Y'
    while true
      if @rock.nil?
        break if @rock_count > @max_rock_count
        @rock = @rocks.next
        #puts "ADDING ROCK #{@rock.inspect}, HIGHEST=#{@highest_rock}"
        y = @highest_rock
        while y >= 0 && @arena[y] > 0
          y -= 1
        end
        @highest_rock = y + 1 if y < @bottom
        puts "HIGHEST ROCK: #{@highest_rock}, y = #{y}" if ENV['DEBUG'] == 'Y'
        @rock_pos = Point.new(@rock_start.x, y - @rock_start.y)
        expand_arena
        @rock_count += 1
        if @rock_count > 1
          trim_stopped
        end
        pb.increment
        puts "HIGHEST ROCK: #{@highest_rock}" if ENV['DEBUG'] == "Y"
        puts "ROCK #{@rock_count} POS #{@rock_pos} BOTTOM: #{@bottom}" if ENV['DEBUG'] == "Y"
        draw_arena if ENV['DEBUG'] == "Y"
        cycle_check
      end
      #draw_arena if ENV['DEBUG'] == 'Y'
      blow_jet
      #draw_arena if ENV['DEBUG'] == 'Y'
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
