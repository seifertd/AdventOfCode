class Solution
  def part1
    good = 0
    input do |line|
      answer, eq = line.split(": ")
      answer = answer.to_i
      nums = eq.split(/\s+/).map(&:to_i)
      results = []
      nums.each.with_index do |n, i|
        if results.size == 0
          results << n
        else
          next_res = []
          last_n = 2 ** (i-1)
          results.last(last_n).each do |p|
            next_res << n + p
            next_res << n * p
          end
          break if next_res.all? {|a| a > answer}
          if next_res.include?(answer)
            good += answer
            break
          end
          results = next_res.uniq
        end
      end
    end
    good
  end
  def part2
    good = 0
    input do |line|
      answer, eq = line.split(": ")
      answer = answer.to_i
      nums = eq.split(/\s+/).map(&:to_i)
      results = []
      found = false
      nums.each.with_index do |n, i|
        if results.size == 0
          results << n
        else
          next_res = []
          last_n = 3 ** (i-1)
          results.last(last_n).each do |p|
            next_res << n + p
            next_res << n * p
            next_res << "#{p}#{n}".to_i
          end
          results = next_res.uniq
        end
      end
      if results.include?(answer)
        debug "FOUND: #{line} IDX: #{results.index(answer)}\n"
        good += answer
        found = true
      else
        if !found
          debug "NOT FOUND: #{answer}\n"
        end
      end
    end
    good
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
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
