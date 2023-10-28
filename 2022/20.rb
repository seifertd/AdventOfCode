def run(a, n, debug = false)
  puts n.inspect if debug
  a.each.with_index do |d, i|
    if d != 0
      idx = n.find_index{|nd, ni| ni == i}
      nidx = idx + d
      nidx = (nidx) % a.size
      puts "#{d} moves from #{idx} -> #{nidx}" if debug
      if d > 0
        # insert after nidx
        n.insert(nidx+1, [d, i])
      else
        # insert before nidx
         n.insert(nidx, [d, i])
      end
      # Remove the old value
      if nidx < idx
        # value at idx will have shifted 1 to right
        n.delete_at(idx + 1)
      else
        n.delete_at(idx)
      end
    end
    puts n.inspect if debug
  end

  idx = n.find_index{|d,i| d == 0}
  sum = n[(idx + 1000) % a.size].first
  sum += n[(idx + 2000) % a.size].first
  sum += n[(idx + 3000) % a.size].first
  sum
end

a = [1,2,-3,3,-2,0,4]
n = a.map.with_index {|d,i| [d,i]}
puts "Part 1: #{run(a,n, true)}"

a = ARGF.readlines.map(&:to_i)
puts "Read #{a.size} lines, first: #{a.first} last: #{a.last} uniq: #{a.uniq.size}"
n = a.map.with_index {|d,i| [d,i]}
puts "Part 2: #{run(a,n)}"

