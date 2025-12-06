class Solution
  def parse
    @fresh = []
    @ids = nil
    line_no = 1
    input do |line|
      if line.empty?
        @ids = []
        next
      end
      if !@ids.nil?
        @ids << line.to_i
      else
        min, max = line.split('-').map(&:to_i)
        if min > max
          raise "LINE: #{line_no} min is > max: #{line}"
        end
        overlaps = []
        @fresh = @fresh.delete_if do |r|
          if (min >= r[0] && min <= r[1]) || (max >= r[0] && max <= r[1]) ||
                (r[0] >= min && r[0] <= max) || (r[1] >= min && r[1] <= max)
            overlaps << r
            true
          else
            false
          end
        end
        overlaps.each do |r|
          min = [min, r[0]].min
          max = [max, r[1]].max
        end
        @fresh << [min, max]
      end
      line_no += 1
    end
  end
  def part1
    parse
    @ids.count do |id|
      @fresh.any? do |r|
        id >= r[0] && id <= r[1]
      end
    end
  end
  def part2
    parse
    @fresh.sort_by! {|r| r[0]}
    count = 0
    @fresh.each.with_index do |r, idx|
      count += r[1] - r[0] + 1
      if idx > 0
        if r[0] <= @fresh[idx-1][1]
          raise "OVERLAPPING RANGE: #{idx} #{r.inspect} #{@fresh[idx-1].inspect}"
        end
      end
    end
    count
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
    puts "Usage: ruby #{__FILE__} [part1|part2] ARGF"
    puts "  ARGF can be the name of a file or a shell redirect of data"
  end
end
