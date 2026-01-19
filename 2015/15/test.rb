def f(x,y)
  c = (-x+2*y)
  d = (-2*x+3*y)
  f = (6*x-2*y)
  t = (3*x-y)
  [c,0].max * [d,0].max * [f,0].max * [t,0].max
end

puts "For the sample:"
puts "s(44,56) = #{f(44,56)}"
puts "s(50,50) = #{f(50,50)}"


def find_positive_combinations(n, target, current_combo = [])
  #puts "FPC: n:#{n} target:#{target} curr:#{current_combo}"
  # Base Case: The final variable must be the remaining target
  if n == 1
    #puts " -> YIELD BASE: #{current_combo + [target]}"
    yield(current_combo + [target])
    return
  end

  # Recursive Case: Start at 1. 
  # Ensure we leave enough remaining (n-1) to allow each to be at least 1.
  (1..(target - (n - 1))).each do |i|
    find_positive_combinations(n - 1, target - i, current_combo + [i]) do |combo|
      #puts " -> FPC: n:#{n} target:#{target} YIELD RECURSE: #{combo}"
      yield combo
    end
  end
end

count = 0
find_positive_combinations(2,100) do |combo|
  count += 1
end
puts "There are #{count} combinations of 2 ingredients summing to 100."

count = 0
find_positive_combinations(4,100) do |combo|
  count += 1
end
puts "There are #{count} combinations of 4 ingredients summing to 100."
