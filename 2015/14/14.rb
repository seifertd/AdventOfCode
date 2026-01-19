class Solution
  Reindeer = Struct.new(:name, :speed, :move_time, :rest_time) do
    def cycle_time
      self.move_time + self.rest_time
    end
    def cycle_distance
      self.move_time * self.speed
    end
    def distance_at_t(t)
      full_cycles, remaining_time = t.divmod(cycle_time)
      full_cycles * cycle_distance + [move_time, remaining_time].min * speed
    end
    def to_s
      "#{self.name}: #{self.speed}km/h @ #{self.move_time}, rest #{self.rest_time}"
    end
    def inspect
      to_s
    end
  end
  def parse
    @reindeer = []
    re = /^([^ ]+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds.$/
    input do |line|
      if md = line.match(re)
        name, speed, move_time, rest_time = md.captures
        @reindeer << Reindeer.new(name,
                                  speed.to_i,
                                  move_time.to_i,
                                  rest_time.to_i)
      else
        raise "Input #{line} does not match regex"
      end
    end
  end
  def race(total_time = 1000)
    runs = @reindeer.map do |r|
      distance = r.distance_at_t(total_time)
      debug { "#{r.name}: time: #{total_time} dist: #{distance}\n"}
      distance
      [r, distance]
    end
    runs.sort_by{|r| -r[1]}.first
  end
  def race_part2(total_time = 1000)
    scores = [0] * @reindeer.size
    1.upto(total_time) do |t|
      distances = @reindeer.map.with_index {|r, i| [i, r.distance_at_t(t)]}.sort_by{|a| -a[1]}
      max = distances.first[1]
      index = 0
      while index < distances.length && distances[index][1] == max
        scores[distances[index][0]] += 1
        index += 1
      end
      debug { "After #{t} seconds, dist: #{distances}, scores: #{scores}\n" }
    end
    scores.max
  end
  def part1
    parse
    debug { "Reindeer: #{@reindeer.inspect}\n" }
    winner, distance = race((ENV['RACE_TIME'] || 1000).to_i)
    debug { "Winner: #{winner}, distance: #{distance}\n" }
    distance
  end
  def part2
    parse
    debug { "Reindeer: #{@reindeer.inspect}\n" }
    race_part2((ENV['RACE_TIME'] || 1000).to_i)
  end
  def input
    if block_given?
      ARGF.each_line do |line|
        line.chomp!
        yield(line)
      end
    else
      return to_enum(:input)
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
