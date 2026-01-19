class Solution
  def parse
    @ingredients = []
    input do |line|
      name, cats = line.split(": ")
      values = cats.scan(/-?\d+/).map(&:to_i)
      @ingredients << [name, *values]
    end
  end
  def score(amounts, req_cals = nil)
    score = 1
    4.times do |cat|
      score *= [amounts.map.with_index do |amt, i|
        i = @ingredients[i]
        amt * i[cat+1]
      end.sum, 0].max
    end
    if !req_cals.nil?
      calories = amounts.map.with_index{|amt,i| amt * @ingredients[i][5] }.sum
      score = 0 unless calories == req_cals
    end
    score
  end
  def find_positive_combinations(n, target, current_combo = [])
    # Base Case: The final value has to be the target
    if n == 1
      yield(current_combo + [target])
      return
    end

    # Recursive Case: Start at 1. 
    # Ensure we leave enough remaining (n-1) to allow each to be at least 1.
    (1..(target - (n - 1))).each do |i|
      find_positive_combinations(n - 1, target - i, current_combo + [i]) do |combo|
        yield combo
      end
    end
  end
  def part1
    parse
    debug { "Ingredients: #{@ingredients}\n" }
    max = 0
    find_positive_combinations(@ingredients.size,100) do |amounts|
      s = score(amounts)
      max = [max, s].max
    end
    max
  end
  def part2
    parse
    debug { "Ingredients: #{@ingredients}\n" }
    max = 0
    find_positive_combinations(@ingredients.size,100) do |amounts|
      s = score(amounts, 500)
      max = [max, s].max
    end
    max
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
