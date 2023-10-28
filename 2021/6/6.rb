
fish_ages = [0] * 9
ARGF.read.split(',').each do |age|
  age = age.to_i
  fish_ages[age] += 1
end

puts "Read: #{fish_ages.inspect}"

puts "START: #{fish_ages.inspect} TOTAL: #{fish_ages.sum}"
256.times do |day|
  # record how many spawn
  spawners = fish_ages[0]
  fish_ages[0] = 0

  # Age the fish
  1.upto(8) do |idx|
    fish_ages[idx-1] += fish_ages[idx]
    fish_ages[idx] = 0
  end

  # Handle the spawners
  fish_ages[8] += spawners
  fish_ages[6] += spawners

  puts "DAY: #{day+1}: #{fish_ages.inspect} TOTAL: #{fish_ages.sum}"
end
puts "END: #{fish_ages.inspect} TOTAL: #{fish_ages.sum}"
