require "../../common/point"

class Solution
  def parse
    @points = []
    @pairs = []
    curr_idx = 0
    input do |line|
      x, y, z = line.split(",").map(&:to_i)
      curr_point = Point.new(x, y, z)
      @points << curr_point
      if @points.size > 1
        @points[0..(@points.size - 2)].each.with_index do |p, p_idx|
          @pairs << [p_idx, curr_idx, curr_point.dist(p)]
        end
      end
      curr_idx += 1
    end
  end
  def part1
    parse
    @pairs.sort_by!{|p| p[2]}
    debug { "Number of points: #{@points.size}\n" }
    debug { "Number of pairs: #{@pairs.size}\n" }
    debug {
      @pairs[0,10].each do |p|
        puts "#{p.inspect} p1:#{@points[p[0]]} p2: #{@points[p[1]]}"
      end
      ""
    }
    @circuits = []
    @pairs[0,(ENV['PAIRS'] || 10).to_i].each do |p|
      existing = @circuits.find_all do |c|
        c.include?(p[0]) || c.include?(p[1])
      end
      if existing.size > 1
        # Delete all these from @circuits
        existing.each { |e| @circuits.delete(e) }

        # Keep the first and combine all the others:
        keep = existing[0]
        keep << p[0] << p[1]
        existing[1..-1].each { |e| keep.merge(e) }
        @circuits << keep
      elsif existing.size == 1
        existing[0] << p[0] << p[1]
      else
        @circuits << Set.new([p[0], p[1]])
      end
      debug { "CIRCUITS: #{@circuits.inspect}\n" }
      #@circuits.each.with_index do |c1, c1_idx|
      #  @circuits.each.with_index do |c2, c2_idx|
      #    next if c2_idx == c1_idx
      #    raise "Circuit #{c1.inspect}(#{c1_idx}) intersects with #{c2.inspect}(#{c2_idx}) while adding pair: #{p.inspect}" if c1.intersect?(c2)
      #  end
      #end
    end
    @circuits = @circuits.to_a.sort_by!{|s| -s.size}
    debug {
      puts "Largest 3 circuits:"
      @circuits[0,3].each {|c| puts c.inspect }
      ""
    }
    @circuits[0,3].map{|s| s.size}.inject(&:*)
  end
  def part2
    parse
    @pairs.sort_by!{|p| p[2]}
    debug { "Number of points: #{@points.size}\n" }
    debug { "Number of pairs: #{@pairs.size}\n" }
    debug {
      @pairs[0,20].each do |p|
        puts p.inspect
      end
      ""
    }
    @circuits = []
    last_point = nil
    @pairs.each do |p|
      last_point = p
      existing = @circuits.find_all do |c|
        c.include?(p[0]) || c.include?(p[1])
      end
      if existing.size > 1
        # Delete all these from @circuits
        existing.each { |e| @circuits.delete(e) }

        # Keep the first and combine all the others:
        keep = existing[0]
        keep << p[0] << p[1]
        existing[1..-1].each { |e| keep.merge(e) }
        @circuits << keep
      elsif existing.size == 1
        existing[0] << p[0] << p[1]
      else
        @circuits << Set.new([p[0], p[1]])
      end
      #@circuits.each.with_index do |c1, c1_idx|
      #  @circuits.each.with_index do |c2, c2_idx|
      #    next if c2_idx == c1_idx
      #    raise "Circuit #{c1.inspect}(#{c1_idx}) intersects with #{c2.inspect}(#{c2_idx}) while adding pair: #{p.inspect}" if c1.intersect?(c2)
      #  end
      #end
      #debug { "CIRCUITS: #{@circuits.inspect}\n" }
      break if @circuits.length == 1 and @circuits[0].size == @points.size
    end
    debug { "Last point: #{last_point.inspect} p1: #{@points[last_point[0]]} p2: #{@points[last_point[1]]}\n" }
    @points[last_point[0]].x * @points[last_point[1]].x
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
