class Solution
  def invalid_id?(id)
    nd = id.digits.count
    if nd.even?
      factor = 10 ** (nd / 2)
      id / factor == id % factor
    else
      false
    end
  end
  def invalid2?(id)
    id = id.to_s
    return false if id.length < 2
    1.upto(id.length / 2) do |len|
      chunks = id.scan(/.{1,#{len}}/)
      #debug { "ID: #{id} CHUNKS: #{chunks.inspect}\n"}
      if chunks[1..-1].all?{|c| c == chunks[0]}
        return true
      end
    end
    false
  end
  def part1
    sum = 0
    input do |line|
      line.split(',').each do |range|
        id1, id2 = range.split("-").map(&:to_i)
        debug { "ID: #{id1}-#{id2}\n" }
        id1.upto(id2) do |id|
          if self.invalid_id?(id) 
            sum += id
            debug { "ID: #{id} is invalid, sum: #{sum}\n" }
          end
        end
      end
    end
    sum
  end
  def part2
    sum = 0
    input do |line|
      line.split(',').each do |range|
        id1, id2 = range.split("-").map(&:to_i)
        debug { "ID: #{id1}-#{id2}\n" }
        id1.upto(id2) do |id|
          if self.invalid2?(id) 
            sum += id
            debug { "ID: #{id} is invalid, sum: #{sum}\n" }
          end
        end
      end
    end
    sum
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
