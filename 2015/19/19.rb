class Solution
  def parse
    @rules = Hash.new{|h,k| h[k] = []}
    @molecule = nil
    reading_rules = true
    input do |line|
      if line.size == 0
        reading_rules = false
        next
      end
      if reading_rules
        source, target = line.split(" => ")
        @rules[source] << target
      else
        @molecule = line
      end
    end
    @mole_re = /[A-Z][a-z]?/
  end
  def part1
    parse
    debug { "Rules: #{@rules} Molecule: #{@molecule}\n" }
    distinct_products = Set.new
    @rules.each do |source, products|
      products.each do |product|
        si = 0
        while i = @molecule.index(source, si)
          new_mol = @molecule.dup
          new_mol[i,source.size] = product
          debug { "#{source} => #{product}: #{new_mol}\n" }
          distinct_products << new_mol
          si = i + source.length
        end
      end
    end
    distinct_products.size
  end
  def as_array(molecule)
    molecule.scan(@mole_re)
  end
  def part2_eq
    parse
    debug { "Rules: #{@rules} Molecule: #{@molecule}\n" }
    number_of_atoms = as_array(@molecule).size
    number_of_rn = as_array(@molecule).count("Rn")
    number_of_ar = as_array(@molecule).count("Ar")
    number_of_y = as_array(@molecule).count("Y")
    debug { "Num Atoms: #{number_of_atoms} Num Rn: #{number_of_rn} Num Ar: #{number_of_ar} Num Y: #{number_of_y}\n" }
    number_of_atoms - number_of_rn - number_of_ar - 2 * number_of_y - 1
  end

  def part2
    parse
    debug { "Rules: #{@rules} Molecule: #{@molecule}\n" }
    reps = @rules.inject([]) do |r, (s, ps)|
      ps.each do |p|
        r << [s, p]
      end
      r
    end
    debug { "REPS: #{reps}\n" }
    target = @molecule.dup
    steps = 0
    while target != 'e'
      tmp = target.dup
      reps.each do |a, b|
        if !target.include?(b)
          next
        end
        target = target.sub(b, a)
        steps += 1
      end
      if tmp == target
        target = @molecule.dup
        steps = 0
        reps = reps.shuffle
      end
    end
    steps
  end

  def part2_bfs
    parse
    debug { "TARGET: #{@molecule}\n" }
    target = as_array(@molecule)
    debug { "TARGET: #{target}\n" }
    start = @rules['e'].map{|p| as_array(p)}
    debug { "STARTING CHAINS: #{start.inspect}\n" }
    path, steps = build_chains_bfs(start, target)
    debug { "FOUND PATH: #{path} STEPS: #{steps}\n" }
    steps || -1
  end
  def print_path(path)
    last_sym = nil
    count = 1
    str = ""
    path.each do |sym|
      if sym != last_sym
        str << (last_sym || '')
        if count > 1
          str << "@#{count}"
        end
        last_sym = sym
        count = 1
      else
        count += 1
      end
    end
    str << "#{last_sym}@#{count}"
    str
  end
  def build_chains_bfs(start, target)
    visited = Set.new
    queue = start.map{|s| visited << s; [s, 1] }
    until queue.empty?
      queue = queue.sort_by{|p, steps| p.zip(target).index{|a,b| a != b} || p.size}
      path, steps = queue.pop
      # Found the path
      return [path, steps] if path == target
      # too long
      next if path.length > target.length
      matching_length = path.find_index.with_index { |p, i| p != target[i] }
      debug { "\rQUEUE SIZE: #{queue.size} MATCH: #{path[0..matching_length]} PATH: #{print_path(path)}" }
      path.each.with_index do |sym, pos|
        next if path[pos] == target[pos]
        @rules[sym].each do |production|
          production = as_array(production)
          new_path = path[0...pos] + production + path[(pos+1)..]

          # too long
          next if new_path.length > target.length
          # mismatch
          # next unless new_path.zip(target).all? {|a,b| a == b}
          
          #debug { "STEP: #{steps} NEW PATH: #{new_path} VISITED? #{visited.include?(new_path)}\n" }

          if !visited.include?(new_path)
            visited.add(new_path)
            queue << [new_path, steps + 1]
          end
        end
      end
    end
  end
  def input
    if block_given?
      ARGF.each_line do |line|
        line.chomp!
        yield(line)
      end
    else
      return to_enum(:input)
    end
  end
  def debug
    print(yield) if ENV['DEBUG']
  end
end

if __FILE__ == $0
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    solution = Solution.new
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    solution = Solution.new
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
