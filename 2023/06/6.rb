Race = Struct.new(:max_time, :max_distance) do
  def ways_to_win
    # See readme, max distance happens when charge time is 1/2 the race max time
    opt_charge_time = self.max_time / 2

    # If max race time is odd, we will win at 0.5T - 0.5 and 0.5T + 0.5, otherwise
    # we will win at 0.5T
    times_won = self.max_time.odd? ? 2 : 1

    # See readme, formula to calculate dist travelled given wait time
    dist = lambda { |t| t * self.max_time - t**2 }
    time = opt_charge_time
    while true
      newtime = time - 1
      newdist = dist.call(newtime)
      if newdist > self.max_distance
        # we will win for newtime and since the dist formula is
        # quadratic and symmetric, we will win for time + 1 as well
        times_won += 2
      else
        break
      end
      time = newtime
    end
    times_won
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
