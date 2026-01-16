require 'csv'

class Solution
  def mutate(str)
    str.scan(/((\d)\2*)/).map do |chunk|
      "#{chunk[0].length}#{chunk[1]}"
    end.join
  end
  def part1
    str = input.to_a.join
    debug { "   str: #{str} #{str.length}\n" }
    40.times do |i|
      str = mutate(str)
    end
    str.length
  end
  Element = Struct.new(:number, :symbol, :sequence, :length, :decays_into) do
    def to_s
      self.symbol
    end
    def inspect
      to_s
    end
  end
  def parse_periodic_table
    @elements = {}
    CSV.foreach("lookandsay.csv", headers: true, header_converters: :symbol) do |row|
      element = Element.new
      element.symbol = row[:symbol]
      element.number = row[:number].to_i
      element.sequence = row[:sequence]
      element.length = row[:sequence].length
      element.decays_into = row[:decays_into].split(".")
      if element.number < 93
        # don't include the "transuranics"
        @elements[element.symbol] = element
      end
    end
  end
  def str_len(str)
    str.map do |elem|
      elem.length
    end.sum
  end
  def str_cat(str)
    str.map do |elem|
      elem.sequence
    end.join
  end
  def mutate_elements(str)
    str.inject([]) do |new_str, elem|
      new_str.concat(elem.decays_into.map{|name| @elements[name]})
      new_str
    end
  end
  def find_element(str)
    el = @elements.values.find{|e| e.sequence == str}
    raise "Could not map input string #{str} to an element" if el.nil?
    el
  end
  def part2
    parse_periodic_table
    str = input.to_a.join
    debug { "str: #{str}\n" }
    str = [find_element(str)]
    50.times do |i|
      str = mutate_elements(str)
    end
    str_len(str)
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
