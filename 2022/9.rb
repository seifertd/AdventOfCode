Point = Struct.new(:x, :y)
rope = 10.times.map do |idx|
  Point.new(0,0)
end
#puts "ROPE: #{rope.inspect}"
require 'matrix'
size_cols = 6
size_rows = 6
board = Matrix.build(size_rows, size_cols) { 0 }
START = 1
VISITED_T = 2
board[0,0] = START | VISITED_T
chase_head = ->(head, tail, last = false) {
  return if (head.x - tail.x).abs <= 1 &&
            (head.y - tail.y).abs <= 1
  tail.x += 1 * (head.x <=> tail.x)
  tail.y += 1 * (head.y <=> tail.y)
=begin
  if (head.x - tail.x).abs > (head.y - tail.y).abs
    # match head y, move towards head x
    tail.y = head.y
    tail.x += 1 * (head.x <=> tail.x)
  else
    # match head x, move towards head y
    tail.x = head.x
    tail.y += 1 * (head.y <=> tail.y)
  end
=end
  board[tail.x, tail.y] |= VISITED_T if last
}

draw_board = ->(draw = START) {
  (board.row_size - 1).downto(0) do |row|
    board.column_size.times do |col|
      rope_seg = rope.find_index{|seg| seg.x == row && seg.y == col}
      if !rope_seg
        state = board[row,col]
        if (state & draw & VISITED_T) > 0
          print '#'
        elsif (state & draw & START) > 0
          print 's'
        else
          print '.'
        end
      else
        print rope_seg == 0 ? 'H' : rope_seg.to_s
      end
    end
    puts
  end
}

grow_pos = ->(dir) {
  dir == 'R' ? size_cols += 1 : size_rows += 1
  new_board = Matrix.build(size_rows, size_cols) { 0 }
  board.row_size.times do |row|
    board.column_size.times do |col|
      new_board[row,col] = board[row,col]
    end
  end
  board = new_board
}

grow_neg = ->(dir) {
  #puts "START: GROW NEG #{dir}: HEAD: #{rope[0].inspect}"
  coff = 0
  roff = 0
  if dir == 'L'
    coff = 1
    size_cols += 1
  else
    roff = 1
    size_rows += 1
  end
  new_board = Matrix.build(size_rows, size_cols) { 0 }
  board.row_size.times do |row|
    board.column_size.times do |col|
      new_board[row+roff, col+coff] = board[row,col]
    end
  end
  board = new_board
  rope.each do |s|
    s.x += roff
    s.y += coff
  end
  #puts "END: GROW NEG #{dir}: HEAD: #{rope[0].inspect}"
}

count = 0
#draw_board.call
ARGF.each_line do |line|
  line.chomp!
  dir, steps = line.split(" ")
  #puts line
  steps = steps.to_i
  steps.times do 
    #puts "----------------------------"
    case dir
    when 'R'
      rope[0].y += 1
      grow_pos.call(dir) if rope[0].y >= board.column_count
    when 'L'
      rope[0].y -= 1
      grow_neg.call(dir) if rope[0].y < 0
    when 'U'
      rope[0].x += 1
      grow_pos.call(dir) if rope[0].x >= board.row_count
    when 'D'
      rope[0].x -= 1
      grow_neg.call(dir) if rope[0].x < 0
    end
    1.upto(rope.size - 2) do |i|
      chase_head.call(rope[i-1], rope[i])
    end
    chase_head.call(rope[-2], rope[-1], true)
    #puts "AFTER CHASE: HEAD: #{rope[0].inspect}"
    #draw_board.call
    count += 1
  end
  #break if count > 10
end

#puts "----------------------------"
puts "visited by tail:"
draw_board.call(VISITED_T | START) if board.column_count < 50
count = board.each.count{|v| (v & VISITED_T) > 0}
puts "Part 2: #{count}"


