part = 1
if ARGV.length > 0
  if ARGV[0].match(/^\d+$/)
    part = ARGV.shift.to_i
  end
end

pairs = []
pair = nil
ARGF.each_line.with_index do |line, idx|
  line.chomp!
  if (idx % 3) == 0 
    pair = []
    pairs << pair
    pair << eval(line)
  elsif (idx % 3) == 1
    pair << eval(line)
  end
end

puts "Read #{pairs.size} pairs"

compare = ->(f, s) {
  #puts "COMPARE: #{f.inspect} <=> #{s.inspect}"
  if f.nil?
    return -1
  elsif s.nil?
    return 1
  elsif f.is_a?(Integer) && s.is_a?(Integer)
    return f <=> s
  else
    if f.is_a?(Integer)
      f = [f]
    end
    if s.is_a?(Integer)
      s = [s]
    end
  end
  # If first runs out of items
  if f.size == 0 && s.size > 0
    return -1
  end
  # If second runs out of items
  if s.size == 0 && f.size > 0
    return 1
  end
  # Recursively compare elements
  # handle if f has fewer elements than s by adding nils
  (f + [nil]*[s.size - f.size, 0].max).zip(s).each do |arr|
    res = compare.call(arr.first, arr.last)
    return res if res != 0
  end
  return 0
}


if part == 1
  in_order = 0
  not_in_order = 0
  equal = 0
  result = 0
  pairs.each.with_index do |pair, idx|
    f = pair.first
    s = pair.last
    order = compare.call(f, s)
    if order < 0
      #puts "IN ORDER"
      in_order += 1
      result += (idx + 1)
    elsif order > 0
      not_in_order += 1
      #puts "NOT IN ORDER"
    else
      equal += 1
      #puts "EQUAL?"
    end
    #print "Press any key to continue"
    #STDIN.getc
  end

  puts "#{in_order} Pairs in order"
  puts "#{not_in_order} Pairs not in order"
  puts "#{equal} Pairs are equal?"
  puts "Part 1: #{result}"
else
  all_packets = pairs.inject([]) do |all, pair|
    all << pair.first
    all << pair.last
    all
  end
  puts "Read #{all_packets.size} packets"
  # Add the divider packets
  divider1 = [[2]]
  divider2 = [[6]]
  all_packets << divider1
  all_packets << divider2
  # Sort
  all_packets = all_packets.sort &compare
  key = 1
  all_packets.each.with_index do |packet, idx|
    puts "#{idx}: #{packet.inspect}"
    if packet == divider1 || packet == divider2
      key *= (idx+1)
    end
  end
  puts "Part 2: Key = #{key}"
end
