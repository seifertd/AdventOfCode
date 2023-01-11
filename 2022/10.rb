clock = 0
register = 1
ss = []
crt = []
6.times do
  crt << ['-'] * 40
end

draw_crt = -> {
  6.times do |row|
    puts "#{row}: #{crt[row].zip(crt[row]).join}"
  end
}

draw_pixel = ->(line) {
  row = (clock-1) / 40
  col = (clock-1) % 40
  if ((col-1)..(col+1)).include?(register)
    crt[row][col] = "\u{2588}"
  else
    crt[row][col] = " "
  end
  #puts "CLOCK: #{clock} R: #{register} r,c:#{row},#{col} CMD: #{line}"
  #draw_crt.call
}
ARGF.each_line do |line|
  line.chomp!
  instr, arg = line.split(" ");
  arg = arg.to_i if !arg.nil?
  ss << (clock + 1) * register
  case instr
  when 'noop'
    clock += 1
    draw_pixel.call(line)
  when 'addx'
    clock += 1
    draw_pixel.call(line)
    ss << (clock + 1) * register
    clock += 1
    draw_pixel.call(line)
    register += arg
  end
  #break if clock >= 40
end

if false
  sum = 0
  ss.each_with_index do |ss, clock|
    if clock % 40 == 19 
      puts "C: #{clock+1} ss: #{ss}"
      sum += ss
    end
  end

  puts "Part 1: #{sum}"
else
  puts "Part 2:"
  draw_crt.call
end
