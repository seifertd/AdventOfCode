sum = 0
lines = []
ARGF.each_line do |line|
  line.chomp!
  lines << line
end
lines.each_slice(3) do |group|
  puts "group: #{group.inspect}"
  inter = group[0].split(//).intersection(group[1].split(//)).intersection(group[2].split(//)).first
  puts "INTER: #{inter}"
  if inter.ord >= 97
    sum += inter.ord - 96
  else
    sum += inter.ord - 38
  end
end
puts "SUM: #{sum}"




=begin
ARGF.each do |line|
  line.chomp!
  c1 = line[0...(line.size/2)]
  c2 = line[(line.size/2)..-1]
  puts "line: #{line}"
  puts "C1: #{c1}"
  puts "C2: #{c2}"
  inter = c1.split(//).intersection(c2.split(//)).first
  if inter.ord >= 97
    sum += inter.ord - 96
  else
    sum += inter.ord - 38
  end
end
puts "SUM: #{sum}"
=end
