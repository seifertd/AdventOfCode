class Solution
  module Level
    HI = 0
    LO = 1
  end
  Pulse = Struct.new(:count, :level, :source, :target) do
    def to_s
      "P[#{self.count}][#{self.level == Level::LO ? 'lo' : 'hi'}]: #{self.source} -> #{self.target}"
    end
    def inspect
      to_s
    end
  end
  Circuit = Struct.new(:modules) do
    attr_accessor :pulse_counts, :monitor_captures, :monitors
    def initialize(modules: nil)
      super(modules || {})
      @pulses = []
      @pulse_counts = Hash.new { |h,k| h[k] = 0 }
      @monitors = {}
      @monitor_captures = {}
    end
    def add_monitor(node, level)
      @monitors[node] = level
    end
    def push_button(count = 1)
      @pulses << Pulse.new(count, Level::LO, :button, :broadcaster)
      handle_pulses
    end
    def handle_pulses
      while !@pulses.empty?
        p = @pulses.shift
        @pulse_counts[p.level] += 1
        if @monitors.has_key?(p.source) && @monitors[p.source] == p.level
          @monitor_captures[p.source] ||= p.count
        end
        handle_pulse(p)
      end
    end
    def handle_pulse(p)
      if !self.modules.has_key?(p.target)
        # Ignore this pulse, we are at a terminator
      else
        target = self.modules[p.target]
        new_pulses = target.handle_pulse(p)
        @pulses.concat new_pulses
      end
    rescue Exception => e
      STDERR.puts "EXCEPTION: #{e}"
      STDERR.puts "Pulse: #{p}"
      exit 42
    end
  end
  Broadcaster = Struct.new(:name, :targets) do
    def handle_pulse(p)
      targets.map do |t|
        Pulse.new(p.count, p.level, :broadcaster, t)
      end
    end
  end
  FlipFlop = Struct.new(:name, :targets, :on) do
    def initialize(name, targets)
      super(name, targets, false)
    end
    def handle_pulse(p)
      if p.level == Level::HI
        []
      else
        was_on = self.on
        self.on = !self.on
        self.targets.map do |t|
          Pulse.new(p.count, was_on ? Level::LO : Level::HI, self.name, t)
        end
      end
    end
  end
  Conjunction = Struct.new(:name, :targets, :last_inputs) do
    def initialize(name, targets)
      super(name, targets, {})
    end
    def handle_pulse(p)
      last_inputs[p.source] = p.level
      new_level = Level::HI
      if last_inputs.values.all? {|l| l == Level::HI}
        new_level = Level::LO
      end
      self.targets.map do |t|
        Pulse.new(p.count, new_level, self.name, t)
      end
    end
  end
  def parse
    @circuit = Circuit.new
    input do |line|
      if line.start_with?('broadcaster')
        targets = line.split(" -> ")[1].split(", ").map(&:to_sym)
        @circuit.modules[:broadcaster] = Broadcaster.new(:broadcaster, targets)
      else
        type = line[0]
        name, targets = line[1..-1].split(" -> ")
        targets = targets.split(", ").map(&:to_sym)
        name = name.to_sym
        @circuit.modules[name] = type == '%' ? FlipFlop.new(name, targets) : Conjunction.new(name, targets)
      end
    end
    @circuit.modules.each do |name, mod|
      mod.targets.each do |targ|
        targ_mod = @circuit.modules[targ]
        if targ_mod.is_a?(Conjunction)
          targ_mod.last_inputs[name] = Level::LO
        end
      end
    end
  end
  def part1
    parse
    Solution::debug { "#{@circuit.inspect}\n" }
    1000.times do
      @circuit.push_button
    end
    Solution::debug { "\nCOUNTS: #{@circuit.pulse_counts.inspect}\n" }
    @circuit.pulse_counts.values.inject(&:*)
  end
  def part2
    parse
    # Looking at input using graphviz to produce a digraph diagram (use the 
    # included dotify.sh script to produce a dot file from your input:
    #
    # > ./dotify.sh input.txt > input.dot
    # Then generate the graph diagram using graphviz:
    # > dot -Tpng -oinput.png input.dot
    #
    # We see the circuit consists of N blobs of flip flops each of which leads
    # down to rx via a conjunction module. At the bottom of this graph, we have
    # the following:
    # conj X (N of these) -> conj Y -> rx
    # we find the N conj X's going into rx thru conj Y. As soon as these are all HI, the
    # conj Y node will send a LO to rx. Need to determine when this will happen.
    # If we assume that each of conj X flips to HI on a cycle (big ASSumption)
    # then rx will receive a LO on the LCM of the cycle counts. But AoC is fond
    # of LCM problems.
    # Blind alleys and blunders: We have to determine at which button press
    # each of the conj X SENT a HI to the conj Y. Keeping track of the
    # last sent pulse by each conjunction doesn't work because often during a button
    # press, the conj X modules will send a HI to conj Y, but then send a bunch of
    # LO's to it as the queue of pulses is drained. The mistake is looking for the
    # LO signals being sent to rx as the last signal of the button press. The
    # instructions don't say that has to hold.
    # We CAN however assume that if conj X sends a HI to conj y, the next signal
    # to be processed will be from the next conj X in the graph. This is due to the
    # circuit using a FIFO to process the signals and each conj X is at the same
    # depth in the digraph.
    conj_y = @circuit.modules.values.find { |mod| mod.targets == [:rx]}
    conj_x_names = @circuit.modules.values.find_all { |mod| mod.targets == [conj_y.name] }.map(&:name)
    Solution::debug { "Modules of interest: #{conj_x_names.inspect}\n" }
    conj_x_names.each do |n|
      @circuit.add_monitor(n, Level::HI)
    end
    count = 1 
    loop do
      @circuit.push_button(count)
      break if @circuit.monitors.keys.all?{|k| @circuit.monitor_captures.has_key?(k)}
      break if count > 10_000_000
      count += 1
    end
    Solution::debug { "CAPTURES: #{@circuit.monitor_captures.inspect}\n" }
    @circuit.monitor_captures.values.inject(&:lcm)
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def self.debug
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
