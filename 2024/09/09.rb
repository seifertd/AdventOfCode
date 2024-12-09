Block = Struct.new(:id, :size, :marked)
class Solution
  def print_disk(disk)
    disk.each do |b|
      if b.id >= 0
        print "#{b.id}" * b.size
      else
        print '.' * b.size
      end
      print ' '
    end
    puts
  end
  def compact(disk, full = false)
    if last_blk_rev_idx = disk.reverse_each.find_index {|b| b.id > 0 && ( !full || !b.marked)}
      last_blk_idx = disk.length - 1 - last_blk_rev_idx
      last_blk = disk[last_blk_idx]
    else
      return nil
    end
    data_to_move = last_blk.size
    #puts "LAST BLOCK IDX: #{last_blk_idx}"
    while data_to_move > 0
      first_free_idx = disk.find_index do |b|
        b.id < 0 && ( !full || b.size >= last_blk.size )
      end
      #puts "FIRST FREE IDX: #{first_free_idx}"
      # No more to compact
      if full && first_free_idx.nil?
        last_blk.marked = true
        return -1
      end
      if full && first_free_idx > last_blk_idx
        last_blk.marked = true
        return -1
      end
      if first_free_idx == last_blk_idx + 1
        return nil
      end
      first_free_blk = disk[first_free_idx]
      if first_free_blk.size > last_blk.size
        disk.insert(first_free_idx, last_blk.dup)
        # reduce free block
        first_free_blk.size -= last_blk.size
        data_to_move = 0
      elsif first_free_blk.size == last_blk.size
        disk[first_free_idx] = last_blk.dup
        data_to_move = 0
      else
        first_free_blk.id = last_blk.id
        data_to_move -= first_free_blk.size
        last_blk.size -= first_free_blk.size
      end
    end
    last_blk.id = -1
    last_blk.marked = true
  end
  def read_disk
    disk = []
    id = 0
    file = true
    ARGF.read.chomp.split(//).map(&:to_i).each do |n|
      if file
        disk << Block.new(id, n)
        id += 1
      else
        disk << Block.new(-1, n)
      end
      file = !file
    end
    disk
  end
  def part1
    disk = read_disk
    while compact(disk)
    end
    checksum(disk)
  end
  def checksum(disk)
    position = 0
    sum = 0
    disk.each do |b|
      if b.id == -1
        position += b.size
        next
      end
      b.size.times do
        sum += position * b.id
        position += 1
      end
    end
    sum
  end
  def part2
    disk = read_disk
    while compact(disk, true)
      #print_disk(disk)
    end
    #print_disk(disk)
    #10.times do
    #  compact(disk, true)
    #  print_disk(disk)
    #end
    checksum(disk)
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug(msg)
    print(msg) if ENV['DEBUG']
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
