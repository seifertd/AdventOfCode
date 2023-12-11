def parse_sequences
  ARGF.readlines.map do |line|
    line.chomp.split(" ").map(&:to_i)
  end
end

def extrapolate(seq, last = true)
  tri = [seq]
  while !tri.last.all?{|v| v == 0}
    tri << tri.last.each_cons(2).map{|f, s| s - f}
    #puts "TRI: #{tri.inspect}"
  end
  delta = 0
  tri.reverse.each do |seq|
    if last
      delta = seq.last + delta
    else
      delta = seq.first - delta
    end
  end
  delta
end

def part1(seqs)
  seqs.map{|s| extrapolate(s)}.sum
end
def part2(seqs)
  seqs.map{|s| extrapolate(s, false)}.sum
end

seqs = parse_sequences
puts "Part 1: #{part1(seqs)}"
puts "Part 2: #{part2(seqs)}"
