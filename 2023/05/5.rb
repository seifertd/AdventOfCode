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

puts "Part 1: #{part1(a)}"
