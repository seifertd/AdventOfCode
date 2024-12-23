require 'set'

class Solution
  def confab(secret)
    n = secret * 64
    secret = n ^ secret
    secret = secret % 16777216
    n = secret / 32
    secret = n ^ secret
    secret = secret % 16777216
    n = secret * 2048 
    secret = n ^ secret
    secret = secret % 16777216
  end
  def part1
    sum = 0
    input do |line|
      secret = line.to_i
      orig_n = secret
      2000.times { secret = confab(secret) }
      debug { "ORIG: #{orig_n} => #{secret}\n"}
      sum += secret
    end
    sum
  end
  def part2

    inputs_to_prices = []
    input do |line|
      seq_to_price = Hash.new {|h,k| h[k] = nil}
      secret = line.to_i
      prev = secret % 10
      diffs = []
      2000.times do
        secret = confab(secret)
        price = secret % 10
        diffs << (price - prev)
        if diffs.size == 4
          seq = diffs.join(",")
          seq_to_price[seq] ||= price
          diffs.shift
        end
        prev = price
      end
      inputs_to_prices << seq_to_price
      debug { "INPUT: #{line} UNIQUE SEQUENCES: #{seq_to_price.size} PRICE[-2,1,-1,3] = #{seq_to_price["-2,1,-1,3"]}\n"}
    end
    uniq_seqs = inputs_to_prices.inject(Set.new) { |set, seq_to_price| set | seq_to_price.keys }.to_a
    debug { "UNIQUE SEQUENCES FOR ALL INPUTS: #{uniq_seqs.size}\n" }
    prices = uniq_seqs.map do |seq|
      inputs_to_prices.sum do |seq_to_price|
        seq_to_price[seq] || 0
      end
    end
    max = prices.max
    index = prices.index(max)
    debug { "MAX PRICES IS #{max} AT INDEX #{index} WITH SEQ: #{uniq_seqs[index]}\n"}
    max
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
