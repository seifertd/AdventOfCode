State = Struct.new(:count)
Springs = Struct.new(:patterns, :fills) do

  CACHE = {}

  def count2(pattern, fills)

    #puts "COUNT2: #{pattern.join} FILLS: #{fills.join(",")} CACHE: #{CACHE.inspect}"
    #puts "COUNT2: #{pattern.join} FILLS: #{fills.join(",")}" 

    if pattern.empty? && !fills.empty?
      #puts "   -> NO MATCH"
      return 0
    elsif pattern.empty? && fills.empty?
      #puts "   -> MATCH"
      return 1
    end

    key = "#{pattern.join}-#{fills.join(',')}"
    val = CACHE[key]
    if !val.nil?
      return val
    end

    val = nil
    if pattern[0] == '.'
      new_pattern = pattern[1..-1]
      val = count2(new_pattern, fills)
    elsif pattern[0] == '?'
      new_pattern = pattern.dup
      new_pattern[0] = '#'
      c1 = count2(new_pattern, fills)
      new_pattern[0] = '.'
      c2 = count2(new_pattern, fills)
      val = c1 + c2
    else
      if fills.size == 0
        #puts "   -> FOUND # CHAR WITH NO FILL, NO MATCH"
        val = 0
      else
        #puts "      = GOT A # CHAR IN #{pattern.join}"
        idx = 1
        group_size = 1
        while idx < pattern.length && pattern[idx] != '.' && group_size < fills[0]
          group_size += 1
          idx += 1
        end
        #puts "      = AFTER LOOK AHEAD, IDX: #{idx} GROUP_SIZE: #{group_size}"
        if group_size == fills[0]
          if group_size == pattern.length || pattern[group_size] != '#'
            new_pattern = pattern.dup
            (group_size + 1).times { new_pattern.shift }
            val = count2(new_pattern, fills[1..-1])
          else
            #puts "   -> Could not match fill of size #{fills[0]} with #{pattern.join}"
            val = 0
          end
        else
          #puts "  -> Ran out of # chars, no match for fill of size #{fills[0]} with #{pattern.join}"
          val = 0
        end
      end
    end
    CACHE[key] = val
    val
  end

  def count(pattern, fills)
    #puts "COUNTING #{pattern.inspect} FILLS: #{fills.inspect}"
    state = State.new(0)
    count_dfs(pattern, fills, state, 0, [])
    state.count
  end

  def get_spots(poss)
    spots = []
    i = 0
    poss_len = poss.length
    while i < poss_len
      if poss[i] == '.'
        i += 1
        next
      end
      j = i + 1
      while j < poss_len && poss[j] == '#'
        j += 1
      end
      spots << j-i
      i = j
    end
    spots
  end

  def count_dfs(pattern, fills, state, p_idx, poss)
    #puts "DFS: STATE: #{state.inspect} POSS: #{poss.join} P_IDX: #{p_idx}"
    poss_len = poss.length
    prev_p_idx = p_idx
    return if poss_len > pattern.length
    if poss_len == pattern.length
      #puts "RECURSION DONE."
      spots = get_spots(poss)
      if spots == fills
        state.count += 1
      end
      return
    end
    while p_idx < pattern.length && pattern[p_idx] != '?'
      poss << pattern[p_idx]
      p_idx += 1
    end
    if p_idx < pattern.length
      # we reached a question mark, skip past it
      p_idx += 1
      #puts "WILL RECURSE: #{state.inspect} POSS: #{poss.inspect}"
      poss << '#'
      spots = get_spots(poss)
      if !prune_poss(pattern, fills, state, poss, spots)
        # look ahead if possible and consume more
        count_dfs(pattern, fills, state, p_idx, poss)
      end
      poss.pop
      poss << '.'
      spots = get_spots(poss)
      if !prune_poss(pattern, fills, state, poss, spots)
        count_dfs(pattern, fills, state, p_idx, poss)
      end
      poss.pop
      p_idx -= 1
    else
      # we are done, recurse again to check end condition
      #puts "DONE? POSS: #{poss.inspect} STATE: #{state.inspect} PATTERN: #{pattern.inspect}"
      count_dfs(pattern, fills, state, p_idx, poss)
    end
    while p_idx > prev_p_idx
      p_idx -= 1
      poss.pop
    end
  end

  def prune_poss(pattern, fills, state, poss, spots)
    return true if spots.size > fills.size

    # look ahead in pattern to see if last spot is compatible
    if poss.last == '#'
      if spots.last == fills[spots.size - 1]
        # next char in pattern has to be a '?' or '.', otherwise prune
        return true if pattern[poss.size] == '#'
      elsif spots.last < fills[spots.size - 1]
        # next char in pattern has to be a '?' or '#', otherwise prune
        return true if pattern[poss.size] == '.'
      end
    end

    spots.each.with_index.any? do |s, idx|
      s > fills[idx]
    end
  end

  def count_fills(pattern, fills)
    poss = get_poss(pattern, fills)
    poss.select do |f|
      spots = get_spots(f)
      spots == fills
      #puts "POSS: #{f.inspect} SPOTS: #{spots.inspect}"
    end.size
  end

  def get_poss(pattern, fills)
    fills = fills.dup
    poss = [[]]
    pattern.each do |c|
      if c == '.' || c == '#'
        poss.each do |f|
          f << c
        end
      else
        cposs = poss.map do |f|
          f.dup
        end
        poss.each do |f|
          f << '.'
        end
        cposs.each do |f|
          f << '#'
        end
        poss.concat(cposs)
      end
    end
    poss
  end
end

def parse_springs
  springs = Springs.new
  springs.patterns = []
  springs.fills = []
  ARGF.each_line do |line|
    line.chomp!
    pattern, fill = line.split(' ')
    springs.patterns << pattern.split(//)
    springs.fills << fill.split(',').map(&:to_i)
  end
  springs
end

def part1(springs)
  springs.patterns.map.with_index do |pattern, i|
    #springs.count_fills(pattern, springs.fills[i])
    #count1 = springs.count(pattern, springs.fills[i])
    count = springs.count2(pattern, springs.fills[i])
    #puts "PATTERN #{i}: COUNT1: #{count1} COUNT2: #{count}"
    CACHE.clear
    count
  end.sum
end

def part2(springs)
  springs.patterns.map.with_index do |pattern, i|
    p = pattern + (['?'] + pattern) * 4
    f = springs.fills[i] * 5
    count = springs.count2(p, f)
    #puts "PATTERN #{i}: COUNT: #{count}"
    CACHE.clear
    count
  end.sum
end

springs = parse_springs

puts "Part 1: #{part1(springs)}"
puts "Part 2: #{part2(springs)}"

