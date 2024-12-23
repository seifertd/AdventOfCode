require '../../common/point'

class Keypad
  def initialize(rows, cols, buttons)
    @rows = rows
    @cols = cols
    @button_map = Hash.new{|h,k| h[k] = []}
    @pad = Array.new(rows) { Array.new(cols, nil)}
    @buttons = buttons
    buttons.each {|b, p| @pad[p.y][p.x] = b}
    rows.times do |y|
      cols.times do |x|
        @gap = Point.new(x,y) if @pad[y][x].nil?
        @curr = @reset = Point.new(x,y) if @pad[y][x] == :A
      end
    end
    buttons.values.each do |b1|
      buttons.values.each do |b2|
        next if b2 == b1
        paths = [[b1]]
        dx = b2.x - b1.x; dx = dx == 0 ? dx : dx / dx.abs
        dy = b2.y - b1.y; dy = dy == 0 ? dy : dy / dy.abs
        #puts "FINDING: #{b1} -> #{b2} dx:#{dx} dy:#{dy} PATHS: #{paths.inspect}"
        while paths.any?{|p| p.last != b2}
          if paths.size > 10
            puts "OVERFLOW: #{b1} -> #{b2} dx:#{dx} dy:#{dy} PATHS: #{paths.inspect}"
            exit 42
          end
          paths.size.times do |pidx|
            path = paths[pidx]
            lp = path.last
            next if lp == b2
            nps = []
            if dx != 0
              nps << Point.new(lp.x + dx, lp.y)
            end
            if dy != 0
              nps << Point.new(lp.x, lp.y + dy)
            end
            nps.reject! do |p|
              p == @gap || (dy < 0 && p.y < b2.y) || (dy > 0 && p.y > b2.y) || (dx < 0 && p.x < b2.x) || (dx > 0 && p.x > b2.x)
            end
            #puts "PATH: #{path.inspect} B2: #{b2} NPS: #{nps.inspect}"
            opath = Marshal.load(Marshal.dump(path))
            nps.each.with_index do |p, idx|
               if idx == 0
                 path << p
               else
                 npath = Marshal.load(Marshal.dump(opath))
                 npath << p
                 paths << npath
              end
            end
          end
        end
        #puts "FOUND: #{b1} -> #{b2} dx:#{dx} dy:#{dy} PATHS: #{paths.inspect}"
        @button_map[[b1,b2]] = paths
      end
    end
  end
  def reset
    @curr = @reset
  end
  def paths(b1, b2)
    @button_map[[b1,b2]]
  end
  def push(b)
    b = @buttons[b]
    ap = self.paths(@curr, b)
    if b == @curr
      return [[:A]]
    end
    @curr = b
    programs = ap.map do |path|
      path.each_cons(2).with_index.map do |pair, idx|
        p1 = pair[0]
        p2 = pair[1]
        p2.direction_from(p1, false)
      end
    end
    programs.each { |p| p << :A}
    programs
  end
  def programs_for(code)
    steps = []
    self.reset
    code.each do |button|
      steps << self.push(button)
    end
    programs = [[]]
    steps.each do |step|
      if step.size == 1
        programs.each { |prog| prog.concat(step.first) }
      else
        oprog = nil
        numprogs = programs.size
        step.each.with_index do |s, idx|
          numprogs.times do |pidx|
            prog = programs[pidx]
            if idx == 0
              oprog = prog.dup
              prog.concat(s)
            else
              nprog = oprog.dup
              nprog.concat(s)
              programs << nprog
            end
          end
        end
      end
    end
    programs = programs.sort_by {|p| p.size}
    shortest = programs[0].size
    programs.find_all{|p| p.size == shortest}.uniq
  end
end
class Solution
  NUMBER_BUTTONS = {
    A: Point.new(2,3), "3": Point.new(2,2), "6": Point.new(2,1), "9": Point.new(2,0),
    "0": Point.new(1,3), "2": Point.new(1,2), "5": Point.new(1,1), "8": Point.new(1,0),
    "1": Point.new(0,2), "4": Point.new(0,1), "7": Point.new(0,0)
  }
  MOVE_BUTTONS = {
    A: Point.new(2,0), "^": Point.new(1,0), ">": Point.new(2,1),
    v: Point.new(1,1), "<": Point.new(0,1)
  }
  def part1
    keypads = [
      Keypad.new(4, 3, NUMBER_BUTTONS),
      Keypad.new(2, 3, MOVE_BUTTONS),
      Keypad.new(2, 3, MOVE_BUTTONS),
    ]
    codes = []
    input do |line|
      codes << line.split(//).map(&:to_sym)
    end
    score = 0
    codes.each do |code|
      opt = Hash.new{|h,k| h[k] = 1_000_000_000}
      kp = keypads[0]
      next_codes = kp.programs_for(code)
      opt[0] = [next_codes.first.size, opt[0]].min
      1.upto(keypads.length - 1) do |kp_idx|
        kp = keypads[kp_idx]
        nnc = []
        next_codes.each do |nc|
          mc = kp.programs_for(nc)
          if mc.first.size <= opt[kp_idx]
            opt[kp_idx] = mc.first.size
            nnc.concat(mc)
          end
        end
        next_codes = nnc
      end
      debug { "CODE: #{code.join} COUNTS: #{opt.inspect}\n"}
      score += code.join.to_i * opt[keypads.length - 1]
    end
    score
  end
  def part1_old
    keypads = [
      Keypad.new(4, 3, NUMBER_BUTTONS),
      Keypad.new(2, 3, MOVE_BUTTONS),
      Keypad.new(2, 3, MOVE_BUTTONS),
    ]
    codes = []
    input do |line|
      codes << line.split(//).map(&:to_sym)
    end
    #new_codes = keypads[0].programs_for(codes[0])
    #puts "#{codes[0]} => #{new_codes.inspect}"
    #code = new_codes[0]
    #new_codes = keypads[1].programs_for(code)
    #puts "#{code.inspect} => #{new_codes.inspect}"
    score = 0
    codes.each do |code|
      new_codes = [code]
      complexity = code.join.to_i
      length = 1
      keypads.each do |kp|
        collect = []
        new_codes.each do |code|
          collect.concat(kp.programs_for(code))
        end
        collect = collect.sort_by{|a| a.size}
        shortest = collect.first.size
        collect.reject!{|a| a.size > shortest}
        new_codes = collect.uniq
        length = new_codes.first.length
      end
      debug { "CODE: #{code.join} #{complexity} x #{length}\n" }
      score += (complexity * length)
    end
    score
  end
  def part2
    raise "part2 solution not implemented"
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
