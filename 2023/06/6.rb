Race = Struct.new(:max_time, :max_distance) do
  def ways_to_win
    opt_charge_time = self.max_time / 2
    times = if self.max_time.odd?
              2
            else
              1
            end
    dist = lambda { |t| t * self.max_time - t**2 }
    time = opt_charge_time
    while true
      newtime = time - 1
      newdist = dist.call(newtime)
      if newdist > self.max_distance
        times += 2
      else
        break
      end
      time = newtime
    end
    times
  end
end

def parse_races
  times, distances = ARGF.readlines
  times = times.split(/\s+/)[1..-1].map(&:to_i)
  distances = distances.split(/\s+/)[1..-1].map(&:to_i)
  times.zip(distances).map do |t, d|
    Race.new(t, d)
  end
end

def part1(races)
  races.map(&:ways_to_win).inject(&:*)
end

def part2(races)
  r = Race.new
  r.max_time = races.map{|r| r.max_time}.join.to_i
  r.max_distance = races.map{|r| r.max_distance}.join.to_i
  r.ways_to_win
end

races = parse_races
puts "Part1: #{part1(races)}"
puts "Part2: #{part2(races)}"
