class Solution
  def has_x_mas(x, y)
    count = 0
    if y - 1 >= 0 && x - 1 >= 0 && y + 1 < @grid.size && x + 1 < @grid.size
      xm = @grid[y][x] == 'A' &&
      (
        (@grid[y-1][x-1] == 'M' && @grid[y-1][x+1] == 'M' &&
          @grid[y+1][x-1] == 'S' && @grid[y+1][x+1] == 'S') || 
        (@grid[y-1][x-1] == 'M' && @grid[y-1][x+1] == 'S' &&
          @grid[y+1][x-1] == 'M' && @grid[y+1][x+1] == 'S') || 
        (@grid[y-1][x-1] == 'S' && @grid[y-1][x+1] == 'S' &&
          @grid[y+1][x-1] == 'M' && @grid[y+1][x+1] == 'M') || 
        (@grid[y-1][x-1] == 'S' && @grid[y-1][x+1] == 'M' &&
          @grid[y+1][x-1] == 'S' && @grid[y+1][x+1] == 'M')
      )
      xm
    end
  end
  def count_words(word, x, y)
    word_count = 0
    row = @grid[y]
    # forward horizontal 
    if x + word.size - 1 < row.size
      grid_word = row[x,word.size].join
      if grid_word == word
        debug "FOUND forward horizontal WORD #{word} at y:#{y},x:#{x}\n"
        word_count += 1
      end
      # forward up diag
      if y >= word.size - 1
        grid_word = []
        word.size.times do |i|
          grid_word << @grid[y-i][x+i]
        end
        if grid_word.join == word
          debug "FOUND FORWARD UP WORD #{word} at y:#{y},x:#{x}\n"
          word_count += 1
        end
      end
      # forward down diag
      if y + word.size - 1 < @grid.size
        grid_word = []
        word.size.times do |i|
          grid_word << @grid[y+i][x+i]
        end
        #puts "FORWARD DOWN WORD AT y:#{y},x:#{x}: #{grid_word.join}\n"
        if grid_word.join == word
          debug "FOUND FORWARD DOWN WORD #{word} at y:#{y},x:#{x}\n"
          word_count += 1
        end
      end
    end
    # backward horizontal
    if x >= word.size - 1
      grid_word = row[x - word.size + 1,word.size].join.reverse
      if grid_word == word
        debug "FOUND BACKWARD HORIZ WORD #{word} at y:#{y},x:#{x}\n"
        word_count += 1
      end
      # backward up diag
      if y >= word.size - 1
        grid_word = []
        word.size.times do |i|
          #debug "BACKWARD UP LETTER AT y:#{y-i},x:#{x-i} = #{@grid[y-i][x-i]}\n"
          grid_word << @grid[y-i][x-i]
        end
        if grid_word.join == word
          debug "FOUND BACKWARD UP WORD #{word} at y:#{y},x:#{x}\n"
          word_count += 1
        end
      end
      # backward down diag
      if y + word.size - 1 < @grid.size
        grid_word = []
        word.size.times do |i|
          grid_word << @grid[y+i][x-i]
        end
        if grid_word.join == word
          debug "FOUND BACKWARD DOWN WORD #{word} at y:#{y},x:#{x}\n"
          word_count += 1
        end
      end
    end
    # down vertical
    if y + word.size - 1 < @grid.size
      grid_word = []
      word.size.times do |i|
        grid_word << @grid[y+i][x]
      end
      if grid_word.join == word
        debug "FOUND DOWN VERT WORD #{word} at y:#{y},x:#{x}\n"
        word_count += 1
      end
    end
    # up vertical
    if y >= word.size - 1
      grid_word = []
      word.size.times do |i|
        grid_word << @grid[y-i][x]
      end
      if grid_word.join == word
        debug "FOUND UP VERT WORD #{word} at y:#{y},x:#{x}\n"
        word_count += 1
      end
    end
    word_count
  end
  def read_grid
    @grid = []
    self.input do |line|
      @grid << line.split(//)
    end
  end
  def part1
    read_grid
    total = 0
    #count_words("XMAS", 3, 9)
    @grid.size.times do |y|
      @grid[y].size.times do |x|
        total += count_words("XMAS", x, y)
      end
    end
    total
  end
  def part2
    read_grid
    total = 0
    #has_x_mas(2,1)
    @grid.size.times do |y|
      @grid[y].size.times do |x|
        if has_x_mas(x,y)
          debug("FOUND X MAS AT y:#{y},x:#{x}\n")
          total += 1
        end
      end
    end
    total
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield line
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
  end
end

if __FILE__ == $0
  solution = Solution.new
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
