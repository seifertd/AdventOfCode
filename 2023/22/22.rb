require '../../common/point'

class Solution
  Block = Struct.new(:id, :p1, :p2) do
    def min_z
      [p1.z, p2.z].min
    end
    def max_z
      [p1.z, p2.z].max
    end
    def drop
      p1.z -= 1
      p2.z -= 1
    end
    def to_s
      "Block{#{id}: #{p1}->#{p2}}"
    end
    def inspect
      to_s
    end
  end
  def blocks_at_max_z(z, blocks = @blocks)
    blocks.values.find_all{ |b| b.max_z == z }
  end
  def check_for_overlaps
    cube = Hash.new{|h1,x| h1[x] = Hash.new{|h2,y| h2[y] = Hash.new {|h3,z| h3[z] = nil} } }
    @blocks.values.each do |b|
      if b.p1.z == b.p2.z
        z = b.p1.z
        b.p1.traverse(b.p2, true) do |p|
          if old_block = cube[p.x][p.y][z]
            raise "Got overlap at x=#{p.x},y=#{p.y},z=#{z} between first block #{old_block} and #{b.id}"
          else
            cube[p.x][p.y][z] = b.id
          end
        end
      else
        min_z = [b.p1.z, b.p2.z].min
        max_z = [b.p1.z, b.p2.z].max
        x = b.p1.x
        y = b.p1.y
        min_z.upto(max_z) do |z|
          if old_block = cube[x][y][z]
            raise "Got overlap at x=#{x},y=#{y},z=#{z} between first block #{old_block} and #{b.id}"
          else
            cube[x][y][z] = b.id
          end
        end
      end
    end
  end
  def settle
    @settled = Hash.new{|h1,x| h1[x] = Hash.new {|h2,y| h2[y] = [0, nil]}}
    @blocks.values.find_all{|b| b.p1.z == 1 || b.p2.z == 1}.each do |b|
      max_z = [b.p1.z, b.p2.z].max
      b.p1.traverse(b.p2, true) do |p|
        @settled[p.x][p.y] = [max_z, b.id]
      end
    end
    cands = @blocks.values.find_all {|b| b.p1.z > 1 && b.p2.z > 1 }
    cands = cands.sort_by{|b| b.min_z }
    cands.each do |block|
      block_pts = block.p1.traverse(block.p2, true)
      new_z = block_pts.map {|p| @settled[p.x][p.y][0] }.max + 1
      if block.min_z > new_z
        dz = block.min_z - new_z
        block.p1.z -= dz
        block.p2.z -= dz
      end
      block_pts.each {|p| @settled[p.x][p.y] = [block.max_z, block.id]}
    end
    @supported_by = Hash.new{|h,k| h[k] = Set.new }
    @supports = Hash.new{|h,k| h[k] = Set.new }
    @blocks.values.sort_by {|b| -b.min_z }.each do |block|
      supports = blocks_at_max_z(block.min_z - 1).find_all do |lblock|
        block.p1.traverse(block.p2, true).any? do |p|
          p.y.between?(*[lblock.p1.y, lblock.p2.y].sort) && 
            p.x.between?(*[lblock.p1.x, lblock.p2.x].sort)
        end
      end
      supports.each { |bb| @supports[bb.id].add(block.id) }
      @supported_by[block.id].merge supports.map(&:id)
    end
  end
  def name_for_index(i)
    if i == 0
      return 'A'
    end
    str = ''
    digits = ('A'..'Z').to_a
    while i > 0
      i, remainder = i.divmod(26)
      str.prepend(digits[remainder])
    end
    str
  end
  def parse
    @blocks = {}
    @x_bounds = [1_000_000,-1_000_000]
    @y_bounds = [1_000_000,-1_000_000]
    count = 0
    input do |line|
      p1, p2 = line.split("~")
      p1 = Point.new(*p1.split(',').map(&:to_i))
      p2 = Point.new(*p2.split(',').map(&:to_i))
      @x_bounds[0] = [@x_bounds[0], p1.x, p2.x].min
      @x_bounds[1] = [@x_bounds[1], p1.x, p2.x].max
      @y_bounds[0] = [@y_bounds[0], p1.y, p2.y].min
      @y_bounds[1] = [@y_bounds[1], p1.y, p2.y].max
      bname = name_for_index(count)
      if @blocks[bname]
        raise "DUPLICATE BLOCK NAME #{bname}"
      end
      @blocks[bname] = Block.new(bname, p1, p2)
      count += 1
    end
  end
  def print_settled
    @y_bounds[0].upto(@y_bounds[1]) do |y|
      if y == 0
        print "      "
        @x_bounds[0].upto(@x_bounds[1]) do |x|
          print "%9d" % x
        end
        puts
      end
      print "%4d: " % y
      @x_bounds[0].upto(@x_bounds[1]) do |x|
        print "%4d(%3s)" % [@settled[x][y][0], @settled[x][y][1].to_s]
      end
      puts
    end
  end
  def part1
    parse
    debug { "GOT #{@blocks.size} BLOCKS\n" }
    debug { "X bounds: #{@x_bounds.inspect}\n" }
    debug { "Y bounds: #{@x_bounds.inspect}\n" }
    settle
    check_for_overlaps
    disentegrate = 0
    @blocks.values.sort_by{|b| b.min_z}.each do |block|
      disentegrate += 1 if @supports[block.id].all? do |supported_id|
        (@supported_by[supported_id] - [block.id]).size > 0
      end
    end
    disentegrate
  end
  def part2
    parse
    settle
    check_for_overlaps
    sum = 0
    count = 1
    @blocks.values.sort_by{|b| b.min_z}.each do |block|
      fell = Set.new
      was_ever_queued = Set.new
      queue = [block.id]
      was_ever_queued << block.id
      iters = 0
      while queue.size > 0
        dis_id = queue.pop
        #debug { "BLOCK: #{block.id}(#{count})iter:#{iters}: DISSOLVING: #{dis_id} QUEUE: #{queue.size}\n" }
        would_fall = @supports[dis_id].find_all do |s_id|
          (@supported_by[s_id] - fell - [dis_id]).size == 0
        end
        #debug { "BLOCK: #{dis_id} WOULD_FALL: #{would_fall.inspect}\n" }
        fell.merge would_fall
        would_fall.each { |wf_id| queue << wf_id unless queue.include?(wf_id) || was_ever_queued.include?(wf_id) }
        was_ever_queued.merge queue
        iters += 1
      end
      #debug { "BLOCK: #{block.id} TOTAL: #{fell.size}\n" }
      sum += fell.size
      #debug { "Block #{count} of #{@blocks.size} sum: #{sum}\n" }
      count += 1
    end
    sum
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
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
