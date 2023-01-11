=begin
Section
    123456789
Elf ---------
  1  111      
  2      222  
  3  33       
  4    44    
  5     555 
  6        66
  7  7777777 
=end

=begin
overlaps = 0
ARGF.each do |line|
  line.chomp!
  first, second = line.split(',')
  first = first.split('-').map(&:to_i)
  second = second.split('-').map(&:to_i)
  #print "first: #{first.inspect} second: #{second.inspect}"
  if ((first[0] <= second[0] && first[1] >= second[1]) ||
      (second[0] <= first[0] && second[1] >= first[1]) )
    overlaps += 1
    #print " OVERLAP!"
  end
  #puts
end
puts "Part1 : #{overlaps}"
=end

overlaps = 0
ARGF.each do |line|
  line.chomp!
  first, second = line.split(',')
  first = first.split('-').map(&:to_i)
  second = second.split('-').map(&:to_i)
  if ((first[0] <= second[1] && second[0] <= first[1]) ||
      (second[0] <= first[1] && first[0] <= second[1]))
    overlaps += 1
  end
end

puts "Part 2: #{overlaps}"
