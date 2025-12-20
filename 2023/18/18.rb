require '../../common/point'

class Segment
  attr_accessor :p1, :p2, :prev, :next
  def initialize(p1,p2,prev)
    self.p1 = p1
    self.p2 = p2
    self.prev = prev
  end
  def hseg_at_y(y)
    return nil unless self.vertical?
    [self.prev, self.next].find {|hseg| hseg.p1.y == y }
  end
  def orientation
    if p1.x == p2.x
      if p2.y > p1.y
        :down
      else
        :up
      end
    else
      if p2.x > p2.y
        :right
      else
        :left
      end
    end
  end
  def horizontal?
    [:left, :right].include?(self.orientation)
  end
  def vertical?
    [:up, :down].include?(self.orientation)
  end
  def at_right_angle_to?(seg)
    self.vertical? && seg.horizontal? || self.horizontal? && seg.vertical?
  end
  def to_s
    "Segment: #{p1}->#{p2}:#{orientation} next.nil? #{self.next.nil?} prev.nil? #{self.prev.nil?}\n"
  end
  def inspect
    to_s
  end
end

class RowGaps
  attr_accessor :y1, :y2, :gaps
  def initialize
    @gaps = []
  end
  def overlaps?(x1, x2)
    @gaps.any? do |gap|
      gx1 = gap.first
      gx2 = gap.last
      gx1 >= x1 && gx1 <= x2 || gx2 >= x1 && gx2 <= x2
    end
  end
  def to_s
    "RowGap: y:#{y1}->#{y2} gaps: #{gaps.inspect}\n"
  end
  def inspect
    to_s
  end
end

class Solution
  DIR = {'R' => :e, 'L' => :w, 'U' => :n, 'D' => :s,
         '0' => :e, '2' => :w, '3' => :n, '1' => :s}
  def parse(part = :part1)
    @points = []
    @min_x = @min_y = 1_000_000_000_000
    @max_x = @max_y = 0
    current = start = Point.new(0,0)
    @points << start
    input do |line|
      dir, dist, color = line.split(" ")
      if part == :part2
        dist = color[2,5].to_i(16)
        dir = color[7]
      end
      current = current.move(DIR[dir], dist.to_i)
      @points << current
      @min_x = [@min_x, current.x].min
      @min_y = [@min_y, current.y].min
      @max_x = [@max_x, current.x].max
      @max_y = [@max_y, current.y].max      
    end
    raise "origin is not 0,0" if @points.first.x != 0 || @points.first.y != 0
    raise "last point #{@points.last} is not equal to first point #{@points.first}" if @points.last != @points.first
    @points.pop
    # change origin to 0,0
    @points.each { |p| p.x -= @min_x; p.y -= @min_y }
    @max_x -= @min_x
    @max_y -= @min_y
    @min_x = 0
    @min_y = 0

    @segments = []
    @points.each_cons(2) do |p1, p2|
      seg = Segment.new(p1, p2, @segments.last)
      if seg.prev
        seg.prev.next = seg
      end
      @segments << seg
    end
    # Add the last seg
    lseg = Segment.new(@points.last, @points.first, @segments.last)
    @segments.last.next = lseg
    @segments << lseg
    # connect first and last seg
    @segments.last.next = @segments.first
    @segments.first.prev = @segments.last

    @segments.each.with_index do |s, idx|
      raise "Seg #{idx} has no prev" if s.prev.nil?
      raise "Seg #{idx} has no next" if s.next.nil?
    end

    @vsegs = @segments.find_all{ |s| s.vertical? }.sort_by { |s| [s.p1.x, s.p1.y] }
    @hsegs = @segments.find_all{ |s| s.horizontal? }.sort_by { |s| [s.p1.y, s.p1.x] }
    y_coords = @hsegs.map{|s| s.p1.y}.sort.uniq
    @row_gaps = []
    y_coords.each_cons(2) do |y1, y2|
      gap = RowGaps.new
      gap.y1 = y1
      gap.y2 = y1
      gap.gaps = gaps_at(y1)
      @row_gaps << gap
      if y2 - y1 > 1
        gap = RowGaps.new
        gap.y1 = y1 + 1
        gap.y2 = y2 - 1
        gap.gaps = gaps_at(gap.y2)
        @row_gaps << gap
      end
    end
    # Add last hseg gaps
    gap = RowGaps.new
    gap.y1 = y_coords.last
    gap.y2 = gap.y1
    gap.gaps = gaps_at(gap.y2)
    @row_gaps << gap
    debug { "Points: #{@points.size} x:#{@min_x}-#{@max_x} y:#{@min_y}-#{@max_y}\n" }
    debug { "First 15: #{@points[0,15].inspect}\n" }
    debug { "horizontal segments: #{@hsegs.size} First 10: #{@hsegs[0,10].inspect}\n" }
    debug { "vertical segments: #{@vsegs.size} First 10: #{@vsegs[0,10].inspect}\n" }
    debug { "Row Gaps: #{@row_gaps.size} First 10: #{@row_gaps[0,10].inspect}\n" }
  end
  #PRINT_ROWS = [21,22,23]
  PRINT_ROWS = []
  def gaps_at(y)
    x = @min_x
    gaps = []
    vseg = @vsegs.find{ |s| s.p1.x == x && y.between?(*([s.p1.y, s.p2.y].sort)) }
    crossings = 0
    if vseg
      crossings = 1
      if [vseg.p1.y, vseg.p2.y].include?(y)
        hseg = vseg.hseg_at_y(y)
        x = [hseg.p1.x, hseg.p2.x].max + 1
      else
        x = 1
      end
    end
    puts "#{y}: x=#{x} FIRST VSEG: #{vseg || "NIL"}" if PRINT_ROWS.include?(y)
    loop do
      vseg = @vsegs.find { |s| s.p1.x > x && y.between?(*([s.p1.y, s.p2.y].sort)) }
      puts "#{y}: x:#{x} crossings: #{crossings} NEXT VSEG: #{vseg || "NIL"}, x=#{x}" if PRINT_ROWS.include?(y)
      break if !vseg
      if !crossings.odd?
        gaps << [x, vseg.p1.x - 1]
      end
      if y != vseg.p1.y && y != vseg.p2.y
        # Case 5, crossing a vertical line
        #debug { "#{y}: CASE 5\n" }
        crossings += 1
        x = vseg.p1.x + 1
      else
        if vseg.p1.x == @max_x
          break
        end
        hseg = vseg.hseg_at_y(y)
        next_vseg = hseg.next != vseg ? hseg.next : hseg.prev
        if vseg.orientation == next_vseg.orientation
          crossings += 1
        end
        x = next_vseg.p1.x + 1
      end
    end
    if x <= @max_x
      gaps << [x, @max_x]
    end
    puts "#{y}: FINAL GAPS: #{gaps}" if PRINT_ROWS.include?(y)
    gaps
  end
  def print_grid(force_print = true)
    grid = Hash.new{|h1,row| h1[row] = Hash.new {|h2,col| h2[col] = '.'}}
    @segments.each do |seg|
      seg.p1.traverse(seg.p2) { |p| grid[p.y][p.x] = '#'}
    end
    0.upto(@max_y) do |row|
      row_gap = @row_gaps.find { |rg| row.between?(rg.y1, rg.y2)}
      row_gap.gaps.each do |(x1, x2)|
        grid[row][x1] = '0'
        grid[row][x2] = '0'
      end
      0.upto(@max_x) do |col|
        print grid[row][col] if force_print || PRINT_ROWS.include?(row)
      end
      puts "#{row}: #{(@max_x + 1) - (row_gap.gaps.map{|g| g[1] - g[0] + 1}.inject(&:+) || 0)}" if force_print || PRINT_ROWS.include?(row)
    end
  end
  def solve(part)
    parse(part)
    #print_grid(true)
    area = 0
    raise "FIRST ROW GAP IS NOT AT Y=0" if @row_gaps.first.y1 != 0
    raise "FIRST ROW GAP IS NOT AT Y=0" if @row_gaps.first.y2 != 0
    @row_gaps.each do |row_gap|
      agap = ((@max_x + 1) - (row_gap.gaps.map{|g| g[1] - g[0] + 1}.inject(&:+) || 0)) * (row_gap.y2 - row_gap.y1 + 1)
      debug { "GAP: #{row_gap.y1} -> #{row_gap.y2} gaps: #{row_gap.gaps.inspect} agap: #{agap}\n" }
      area += agap
    end
    area
  end
  def part1
    solve(:part1)
  end
  def part2
    solve(:part2)
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
