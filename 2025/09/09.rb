require "../../common/point"

class Point
  def neighbors(rows, cols)
    [
      Point.new(self.x - 1, self.y),
      Point.new(self.x + 1, self.y),
      Point.new(self.x, self.y - 1),
      Point.new(self.x, self.y + 1)
    ].reject{|p| p.x < 0 || p.y < 0 || p.y >= rows || p.x >= cols}
  end
end

class Segment
  attr_accessor :p1, :p2, :prev, :next
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
    "Segment: #{p1}->#{p2}\n"
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
  def gaps_at(y)
    x = @min_x
    gaps = []
    vseg = @vsegs.find{|s| s.p1.x >= x && y.between?(*[s.p1.y, s.p2.y].sort)}
    #puts "Starting vseg: #{vseg.inspect} x=#{x}"
    crossings = vseg.p1.x == x ? 1 : 0
    while true
      vseg = @vsegs.find{|s| s.p1.x > x && y.between?(*[s.p1.y, s.p2.y].sort)}
      #puts "Got vseg at y=#{y}: crossings: #{crossings} #{vseg.inspect}"
      break if vseg.nil?
      if crossings.even?
        gaps << [x, vseg.p1.x - 1]
        crossings += 1
      else
        if ![vseg.p1.y, vseg.p2.y].include?(y)
          crossings += 1
        end
      end
      x = vseg.p1.x + 1
    end
    gaps << [x, @max_x] if x <= @max_x
    gaps
  end
  def parse
    @points = []
    @segments = []
    @green_points = []
    @min_x = @min_y = 1_000_000_000_000
    @max_x = @max_y = 0
    last_p = nil
    input do |line|
      p = Point.new(*line.split(',').map(&:to_i))
      @points << p
      @min_x = [@min_x, p.x].min
      @min_y = [@min_y, p.y].min
      @max_x = [@max_x, p.x].max
      @max_y = [@max_y, p.y].max
      if !last_p.nil?
        seg = Segment.new
        seg.p1 = last_p
        seg.p2 = p
        seg.prev = @segments.last
        if seg.prev
          @segments.last.next = seg
        end
        @segments << seg
        if last_p.x == p.x
          ys = [p.y, last_p.y].sort
          (ys.first + 1).upto(ys.last - 1) do |y|
            @green_points << Point.new(p.x, y)
          end
        else
          xs = [p.x, last_p.x].sort
          (xs.first + 1).upto(xs.last - 1) do |x|
            @green_points << Point.new(x, p.y)
          end
        end
      end
      last_p = p
    end
    # Add the last segment
    seg = Segment.new
    seg.p1 = @segments.last.p2
    seg.p2 = @segments.first.p1
    seg.prev = @segments.last
    seg.next = @segments.first
    @segments.first.prev = seg
    @segments << seg
    @vsegs = @segments.find_all{|s| s.vertical?}.sort_by{|s| s.p1.x}
    @hsegs = @segments.find_all{|s| s.horizontal?}.sort_by{|s| s.p1.y}
    @row_gaps = []
    @hsegs.each_cons(2) do |hseg1, hseg2|
      #debug { "ROWGAP: #{hseg1.inspect} #{hseg2.inspect}\n" }
      gap = RowGaps.new
      gap.y1 = [hseg1.p1.y, hseg2.p1.y].min
      gap.y2 = gap.y1
      gap.gaps = gaps_at(gap.y2)
      @row_gaps << gap
      gap = RowGaps.new
      gap.y1 = [hseg1.p1.y, hseg2.p1.y].min + 1
      gap.y2 = [hseg1.p1.y, hseg2.p1.y].max - 1
      gap.gaps = gaps_at(gap.y2)
      @row_gaps << gap
    end
    # add last hseg rowgaps
    gap = RowGaps.new
    gap.y1 = [@hsegs.last.p1.y, @hsegs.last.p2.y].max
    gap.y2 = gap.y1
    gap.gaps = gaps_at(gap.y2)
    @row_gaps << gap

    debug { "Points: #{@points.size} GREEN: #{@green_points.size} x:#{@min_x}-#{@max_x} y:#{@min_y}-#{@max_y}\n" }
    debug { "First 10: #{@points[0,10].inspect}\n" }
    debug { "horizontal segments: #{@hsegs.size} First 10: #{@hsegs[0,10].inspect}\n" }
    debug { "vertical segments: #{@vsegs.size} First 10: #{@vsegs[0,10].inspect}\n" }
    debug { "Row Gaps: #{@row_gaps.size} First 10: #{@row_gaps[0,10].inspect}\n" }
  end
  def part1
    parse
    max = [0, nil, nil]
    @points.each.with_index do |p1, p1_idx|
      @points.each.with_index do |p2, p2_idx|
        next if p1_idx == p2_idx
        a = ((p2.x - p1.x).abs + 1) * ((p2.y - p1.y).abs + 1)
        if a > max[0]
          max[0] = a
          max[1] = p1
          max[2] = p2
        end
      end
    end
    debug { "Max: #{max.inspect}\n" }
    max[0]
  end
  def flood
    top_points = @points.find_all { |p| p.y == @min_y }
    # I know this will never happen with my inputs
    raise "More than one top line segment: #{top_points.inspect}" if top_points.size != 2
    p1 = top_points[0]
    p2 = top_points[1]
    # Start with a known inside point
    p = Point.new(p1.x + (p2.x - p1.x) / 2, p1.y + 1)
    debug { "Known inside: #{p} top Segment: p1: #{p1} p2: #{p2}\n"}
    visited = Hash.new{|h,k| h[k] = false}
    visited[p] = true
    @points.each { |p| visited[p] = true}
    @green_points.each { |p| visited[p] = true}
    queue = p.neighbors(@max_y, @max_x).reject do |p|
      visited[p]
    end
    debug { "Starting flood fill with queue: #{queue.inspect}\n" }
    n = 1
    while !queue.empty?
      p = queue.pop
      @green_points << p
      visited[p] = true
      queue.concat(p.neighbors(@max_y, @max_x).reject do |p|
        visited[p] || queue.include?(p)
      end)
      if n % 100 == 0
        debug { "Flood fill #{n} iterations, queue size: #{queue.size} green: #{@green_points.size}\n" }
      end
      n += 1
    end
  end
  def box_in_area(p1,p2)
    min_x = [p1.x, p2.x].min
    max_x = [p1.x, p2.x].max
    min_y = [p1.y, p2.y].min
    max_y = [p1.y, p2.y].max
    debugging = min_x == 15983 && max_x == 84036 && min_y == 16181 && max_y = 83798
    @row_gaps.none? do |row_gap|
      if row_gap.y1 >= min_y && row_gap.y1 <= max_y || row_gap.y2 >= min_y && row_gap.y2 <= max_y
        puts "BOX #{min_x},#{min_y}->#{max_x},#{max_y} is in row_gap: #{row_gap.inspect}" if debugging
        result = row_gap.gaps.any? { |gap| min_x >= gap[0] && min_x <= gap[1] || max_x >= gap[0] && max_x <= gap[1] }
        puts "BOX #{min_x},#{min_y}->#{max_x},#{max_y} overlaps gaps? #{result}" if debugging
        result
      else
        puts "BOX #{min_x},#{min_y}->#{max_x},#{max_y} is NOT in row_gap: #{row_gap.inspect}" if debugging
        false
      end
    end
  end
  def part2
    parse
    max = [0, nil, nil]
    @points.each.with_index do |p1, p1_idx|
      @points.each.with_index do |p2, p2_idx|
        next if p1_idx == p2_idx
        #debug { "Checking box: #{p1} #{p2}\n" }
        if box_in_area(p1, p2)
          #debug { "Box: #{p1} #{p2} is enclosed\n" }
          a = ((p2.x - p1.x).abs + 1) * ((p2.y - p1.y).abs + 1)
          if a > max[0]
            max[0] = a
            max[1] = p1
            max[2] = p2
          end
        else
          #debug { "Box: #{p1} #{p2} is NOT enclosed\n" }
        end
      end
    end
    debug { "Max: #{max.inspect}\n" }
    max[0]
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
