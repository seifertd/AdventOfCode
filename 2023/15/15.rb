def parse_input
  ARGF.readline.chomp.split(",")
end

def hash(s)
  h = 0
  s.split(//) do |c|
    h = ((h + c.ord) * 17) % 256
  end
  h
end

def part1(input)
  input.map do |s|
    hash(s)
  end.sum
end

def part2(input)
  ht = []
  input.each do |s|
    label, focal_len = s.split("=")
    if focal_len.nil?
      label = label[0..-2]
      op = '-'
    else
      op = '='
    end
    h = hash(label)
    bucket = (ht[h] ||= {})
    if op == '='
      bucket[label] = focal_len.to_i
    else
      bucket.delete(label)
    end
  end
  sum = 0
  ht.each.with_index do |bucket, box|
    (bucket || {}).each.with_index do |pair, slot|
      #puts "BOX: #{box+1} SLOT: #{slot+1} FOCAL LEN: #{pair[1]}"
      sum += (box+1) * (slot+1) * pair[1]
    end
  end
  sum
end

input = parse_input
puts "Part 1: #{part1(input)}"
puts "Part 2: #{part2(input)}"
