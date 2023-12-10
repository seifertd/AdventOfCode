class Range
  def overlap?(other)
    (self.begin <= other.begin && self.end > other.begin) ||
      (self.begin > other.begin && other.end >= self.begin)
  end
end

Almanac = Struct.new(:seeds, :maps) do 
  def initialize
    self.maps = []
  end
  def location(seed)
    val = seed
    #puts "SEED: #{seed}"
    maps.each do |m|
      m.each do |range_offset|
        range, offset = range_offset
        #puts  "      Check Range: #{range.inspect} OFFSET: #{offset}"
        if range.include?(val)
          val += offset
          break
        end
      end
      #puts " -> #{val}"
    end
    #puts "LOCATION: #{val}"
    val
  end

  def offset_range(range, offset)
    if range.exclude_end?
      (range.begin+offset...range.end+offset)
    else
      (range.begin+offset..range.end+offset)
    end

  end

  def min_loc(seed_ranges)
    #puts seed_ranges.inspect
    maps.each do |m|
      #puts m.inspect
      mapped_ranges = []
      m.each do |range, offset|
        new_ranges = []
        unmapped_ranges = []
        seed_ranges.each do |seed_range|
          #puts "MAPPING #{seed_range.inspect} WITH MAP RANGE: #{range.inspect}, offset=#{offset}"
          # four cases
          if range.cover?(seed_range)
            mapped_ranges << offset_range(seed_range, offset)
            unmapped_ranges.delete(seed_range)
          elsif seed_range.cover?(range)
            new_ranges << (seed_range.begin...range.begin)
            new_ranges << (range.end+1..seed_range.end)
            mapped_ranges << offset_range((range.begin..range.end), offset)
            unmapped_ranges.delete(seed_range)
          elsif range.overlap?(seed_range)
            if seed_range.begin < range.begin
              mapped_ranges << offset_range((range.begin..seed_range.end), offset)
              new_ranges << (seed_range.begin...range.begin)
            else
              mapped_ranges << offset_range((seed_range.begin..range.end), offset)
              new_ranges << (range.end+1..seed_range.end)
            end
            unmapped_ranges.delete(seed_range)
          else
            unmapped_ranges << seed_range
          end
        end
        #puts "After map: existing #{seed_ranges} new: #{new_ranges} mapped: #{mapped_ranges} unmapped: #{unmapped_ranges}"
        seed_ranges = new_ranges + unmapped_ranges
      end
      #puts "Applied all maps: mapped: #{mapped_ranges}"
      seed_ranges += mapped_ranges
      #puts "Applied all maps: remaining: #{seed_ranges}"
    end
    min = 1e50
    seed_ranges.each do |range|
      min = [min, range.begin].min
    end
    min
  end
end


def parse_almanac
  a = Almanac.new

  map = nil
  ARGF.each_line do |line|
    line.chomp!
    if line.start_with?('seeds: ')
      a.seeds = line.split("seeds: ").last.split(" ").map(&:to_i)
    elsif line.end_with?(" map:")
      map = []
    elsif line == ""
      a.maps << map if !map.nil?
      map = nil
    else
      dest_start, source_start, length = line.split(" ").map(&:to_i)
      map << [(source_start..(source_start+length-1)), (dest_start - source_start)]
    end
  end
  a.maps << map if !map.nil?
  a
end


a = parse_almanac
def part1(a)
  a.seeds.map{|s| a.location(s) }.min
end

def part2(a)
  seed_ranges = a.seeds.each_slice(2).map do |pair|
    (pair[0]..(pair[0]+pair[1]-1))
  end.sort_by{|r| r.begin}
  a.min_loc(seed_ranges)
end

puts "Part 1: #{part1(a)}"
puts "Part 2: #{part2(a)}"
