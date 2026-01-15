require '../../common/point'
require 'chunky_png'

class Mutator1
  def initialize(grid)
    @grid = grid
  end
  def turn_on(i1, i2)
    @grid.fill(1, (i1..i2))
  end
  def turn_off(i1, i2)
    @grid.fill(0, (i1..i2))
  end
  def toggle(i1, i2)
    i1.upto(i2) do |i|
      @grid[i] ^= 1
    end
  end
end
class Mutator2
  def initialize(grid)
    @grid = grid
  end
  def turn_on(i1, i2)
    i1.upto(i2) do |i|
      @grid[i] += 1
    end
  end
  def turn_off(i1, i2)
    i1.upto(i2) do |i|
      if @grid[i] > 0
        @grid[i] -= 1
      end
    end
  end
  def toggle(i1, i2)
    i1.upto(i2) do |i|
      @grid[i] += 2
    end
  end
end
class Solution
  attr_reader :operations, :rows, :cols, :grid
  def perform(oper, c1, c2, mutator)
    i1 = c1.y * @cols + c1.x 
    i2 = i1 + (c2.x - c1.x)
    (c1.y+1).upto(c2.y) do |y|
      ni1 = y * @cols + c1.x
      ni2 = ni1 + (c2.x - c1.x)
      if ni1 == i2 + 1
        i2 = ni2
      else
        debug { "#{oper} #{i1}->#{i2}\n" }
        mutator.send(oper, i1, i2)
        i1 = ni1
        i2 = ni2
      end
    end
    debug { "#{oper} #{i1}->#{i2}\n" }
    mutator.send(oper, i1, i2)
  end
  def parse(rows, cols)
    @rows = rows
    @cols = cols
    @grid = Array.new(@rows * @cols, 0)
    @operations = []
    regex = /^(turn on|turn off|toggle) (\d+,\d+) through (\d+,\d+)$/
    input do |line|
      oper, c1, c2 = line.match(regex).captures
      c1 = Point.new(*c1.split(',').map(&:to_i))
      c2 = Point.new(*c2.split(',').map(&:to_i))
      oper = oper.sub(' ', '_').to_sym
      debug { "OPER: #{oper.inspect} c1: #{c1} c2: #{c2}\n" }
      @operations << [oper, c1, c2]
    end
  end
  def gen_png
    max_b = @grid.max
    png = ChunkyPNG::Image.new(@cols, @rows, ChunkyPNG::Color::WHITE)
    @rows.times do |y|
      @cols.times do |x|
        i = y * @cols + x
        if @grid[i] > 0
          opacity = (@grid[i] * 255.0 / max_b).to_i
          png[x,y] = ChunkyPNG::Color.html_color('green', opacity)
        end
      end
    end
    png.save("image.png")
  end
  def part1
    parse(1_000, 1_000)
    mutator = Mutator1.new(@grid)
    @operations.each do |oper, c1, c2|
      perform(oper, c1, c2, mutator)
    end
    gen_png if ENV['PNG']
    @grid.count(1)
  end
  def part2
    parse(1_000, 1_000)
    mutator = Mutator2.new(@grid)
    @operations.each do |oper, c1, c2|
      perform(oper, c1, c2, mutator)
    end
    gen_png if ENV['PNG']
    @grid.sum
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
