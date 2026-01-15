class Solution
  def nice(word)
    word.scan(/[aeiou]/).length >= 3 && word =~ /(\w)\1/ && word !~ /(ab|cd|pq|xy)/
  end
  def part1
    count_nice = 0
    input.each do |word|
      word_nice = nice(word)
      debug { "WORD: #{word} #{word_nice ? 'nice' : 'naughty'}\n" }
      count_nice += 1 if word_nice
    end
    count_nice
  end
  def nice2(word)
    word =~ /(..).*\1/ && word =~ /(.).\1/
  end
  def part2
    count_nice = 0
    input.each do |word|
      word_nice = nice2(word)
      debug { "WORD: #{word} #{word_nice ? 'nice' : 'naughty'}\n" }
      count_nice += 1 if word_nice
    end
    count_nice
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
