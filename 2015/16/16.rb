class Solution
  DETECTOR = {
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1
  }
  def parse
    @sues = []
    num = 1
    input do |line|
      sue, attrs = line.split(/Sue \d+: /)
      @sues << eval("{num: #{num}, #{attrs}}")
      num += 1
    end
  end
  def part1
    parse
    debug { "Sues: #{@sues.size} Last: #{@sues.last}\n" }
    sues = @sues
    DETECTOR.each do |attr, value|
      sues = sues.find_all{|s| s[attr] == value || s[attr].nil? }
    end
    debug { "After filtering: #{sues}\n" }
    raise "There ought to be only one sue left: #{sues}" if sues.size != 1
    sues.first[:num]
  end
  def part2
    parse
    debug { "Sues: #{@sues.size} Last: #{@sues.last}\n" }
    sues = @sues
    DETECTOR.each do |attr, value|
      sues = sues.find_all do |s|
        if s[attr].nil?
          true
        elsif [:cats, :trees].include?(attr)
          s[attr] > value
        elsif [:pomeranians, :goldfish].include?(attr)
          s[attr] < value
        else
          s[attr] == value
        end
      end
    end
    debug { "After filtering: #{sues}\n" }
    raise "There ought to be only one sue left: #{sues}" if sues.size != 1
    sues.first[:num]
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
