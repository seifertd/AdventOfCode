input = ARGV[0]

PART = 2
if PART == 1
  UNIQ_COUNT = 4
else
  UNIQ_COUNT = 14
end
queue = []
input.split(//).each_with_index do |c, idx|
  queue.push c
  if queue.size >= UNIQ_COUNT
    if queue[-UNIQ_COUNT..-1].uniq.size == UNIQ_COUNT
      puts "Part #{PART}: #{idx + 1}"
      break
    end
  end
end
