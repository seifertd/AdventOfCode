elves = Hash.new {|h,k| h[k] = 0}
index = 1
ARGF.each_line do |line|
  line.chomp!
  if line == ""
    index += 1
    next
  end
  elves[index] += line.to_i
end

puts elves.to_a.sort_by{|a| a.last}.last(3).inject(0){|sum, a| sum+= a.last}.inspect
