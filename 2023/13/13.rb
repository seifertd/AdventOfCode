Map = Struct.new(:rows, :cols, :data) do
  def initialize
    self.data = []
    self.rows = 0
    self.cols = 0
  end
  def add_line(line)
    if self.cols > 0
      raise "line is not same width as others: #{line}" if line.size != self.cols
    end
    data << line.split(//)
    self.cols = data.last.size
    self.rows += 1
  end

  def reflection
     vertical_reflection || horizontal_reflection || raise("Could not find any reflections")
  end

  def vertical_reflection
    found = false
    (0...self.cols-1).each do |c1|
      found = (0...self.rows).to_a.all? do |r|
        self.data[r][c1] == self.data[r][c1+1]
      end
      if found
        #puts "FOUND MATCHING COLS: #{c1},#{c1+1}"
        # backtrack to find beginning of reflection
        reflecting = true
        bc1 = c1 - 1
        bc2 = c1 + 2
        while reflecting && bc1 >= 0 && bc2 < self.cols
          reflecting = (0...self.rows).to_a.all? do |r|
            self.data[r][bc1] == self.data[r][bc2]
          end
          #puts "CHECKING V col #{bc1} <=> #{bc2} matching: #{reflecting}"
          bc1 -= 1
          bc2 += 1
        end
        if reflecting
          #puts "VERTICAL REFLECTION FOUND: #{reflecting}: AT #{c1 + 1}"
          return (c1 + 1)
        end
      end
    end
    nil
  end
  def horizontal_reflection
    found = false
    (0...self.rows-1).each do |r1|
      found = (0...self.cols).to_a.all? do |c|
        self.data[r1][c] == self.data[r1+1][c]
      end
      if found
        # backtrack to find beginning of reflection
        reflecting = true
        br1 = r1 - 1
        br2 = r1 + 2
        while reflecting && br1 >= 0 && br2 < self.rows
          reflecting = (0...self.cols).to_a.all? do |c|
            self.data[br1][c] == self.data[br2][c]
          end
          #puts "CHECKING H row #{br1} <=> #{br2} matching: #{reflecting}"
          br1 -= 1
          br2 += 1
        end
        if reflecting
          #puts "HORIZONTAL REFLECTION FOUND: #{reflecting}: AT #{r1 + 1}"
          return (r1 + 1)*100
        end
      end
    end
    nil
  end
end

def parse_maps
  cur_map = nil
  maps = []
  ARGF.each_line do |line|
    line.chomp!
    if line.empty?
      if !cur_map.nil?
        maps << cur_map
      end
      cur_map = nil
    else
      if cur_map.nil?
        cur_map = Map.new
      end
      cur_map.add_line(line)
    end
  end
  maps << cur_map
  maps
end

def part1(maps)
  maps.map do |m|
    m.reflection
  end.sum
end

maps = parse_maps
puts "Part 1: #{part1(maps)}"
