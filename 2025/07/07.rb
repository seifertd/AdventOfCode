require 'set'

class Solution
  def parse
    @grid = []
    input do |line|
      @grid << line.split(//)
    end
  end
  def part1
    parse
    beams = Set.new [@grid[0].index('S')]
    splits = 0
    1.upto(@grid.length - 2) do |row|
      new_beams = Set.new []
      beams.each do |col|
        if @grid[row][col] == '^'
          splits += 1
          if @grid[row+1][col-1] == '.'
            new_beams << (col-1)
          end
          if @grid[row+1][col+1] == '.'
            new_beams << (col+1)
          end
        elsif @grid[row][col] == '.'
          new_beams << col
        else
          raise "Unknown char in r=#{row},c=#{col}: #{@grid[row][col]}"
        end
      end
      beams = new_beams
      debug { "row: #{row} beams: #{beams.inspect} splits: #{splits}\n" }
    end
    splits
  end

  def part2
    parse
    beams = Hash.new {|h,k| h[k] = 0}
    beams[@grid[0].index('S')] = 1
    1.upto(@grid.length - 2) do |row|
      beams.keys.each do |col|
        if @grid[row][col] == '^'
          splitting = beams[col]
          beams[col] = 0
          if @grid[row+1][col-1] == '.'
            beams[col-1] += splitting
          end
          if @grid[row+1][col+1] == '.'
            beams[col+1] += splitting
          end
        elsif @grid[row][col] == '.'
        else
          raise "Unknown char in r=#{row},c=#{col}: #{@grid[row][col]}"
        end
      end
      debug { "row: #{row} beams: #{beams.inspect}\n" }
    end
    beams.values.inject(&:+)
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
