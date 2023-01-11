stacks = Array.new

part = 2
reading = :stacks
ARGF.each do |line|
  line.chomp!
  if line == ""
    reading = :moves
    #puts "STACK:"
    #puts stacks.inspect
    next
  end
  if reading == :moves
    md = line.match(/move (\d+) from (\d+) to (\d+)/)
    if md
      num = md[1].to_i
      from = md[2].to_i - 1
      to = md[3].to_i - 1
      if part == 1
        num.times do
          crate = stacks[from].pop
          if crate.nil?
            raise "EMPTY STACK #{from}: #{line}"
          end
          stacks[to].push crate
        end
      else
        i1 = stacks[from].size - num
        crates_to_move = stacks[from].slice!(i1..-1)
        if crates_to_move.nil?
          raise "NIL CRATES TO MOVE (i1 = #{i1}): #{line}"
        end
        if crates_to_move.size != num
          raise "stack #{from} doesn't have enough crates (i1 = #{i1}): #{line}"
        end
        crates_to_move.size.times do
          crate = crates_to_move.shift
          stacks[to].push crate
        end
      end
    else
      raise "UNPARSEABLE MOVE: #{line}"
    end
    #puts line
    #puts "STACK:"
    #puts stacks.inspect
  end
  if reading == :stacks
    data = line.scan(/.{3,4}/)
    #puts "STACK DATA: #{data.inspect}"
    data.each_with_index do |chunk, idx|
      stacks[idx] ||= []
      if chunk.chomp.length == 0
        next
      end
      if md = chunk.match(/\[(.)\]/)
        crate = md[1]
        #puts "#{crate} on stack #{idx}"
        stacks[idx].unshift crate
      end
    end
  end
end

puts "Part 1: #{stacks.map(&:last).join}"
