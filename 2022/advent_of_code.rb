class AdventOfCode
  Point = Struct.new(:x, :y, :z) do
    def initialize(x = 0, y = 0, z = 0)
      super(x, y, z)
    end
    def dist(other)
      Math.sqrt(x * other.x + y * other.y + z * other.z)
    end
    def taxi_dist(other)
      (x - other.x).abs + (y - other.y).abs + (z - other.z).abs
    end
    def to_s
      "(#{x},#{y})"
    end
    def inspect
      to_s
    end
  end
  class Cycle
    attr_accessor :counter
    def initialize(array)
      @array = array
      @length = @array.length
      @counter = 0
    end

    def next
      begin
        @array[@counter % @length]
      ensure
        @counter += 1
        if @counter >= @length
          @counter = 0
        end
      end
    end

    def prev
      begin
        @counter -= 1
        @array[@counter % @length]
      ensure
        if @counter < 0
          @counter = @length - 1
        end
      end
    end
  end

  attr_accessor :part
  def initialize(*attr_names)
    @part = 1
    if ARGV.length > 0
      if ARGV[0].match(/^\d+$/)
        @part = ARGV.shift.to_i
      end
    end
    while attr_names.size > 0
      if ARGV.length > 0
        if ARGV[0].match(/^\d+$/)
          self.send("#{attr_names.shift}=".to_sym, ARGV.shift.to_i)
        else
          puts "arg #{attr_names.first} must be an integer, found #{ARGV[0]}"
          puts "Usage: #{$0} [part] #{attr_names.map{|n| "[#{n}]"}.join(' ')} INPUT_FILE"
          exit 1
        end
      else
        puts "Usage: #{$0} [part] #{attr_names.map{|n| "[#{name}]"}.join(' ')} INPUT_FILE"
        exit 2
      end
    end
  end

  def run
    if @part == 1
      part1
    else
      part2
    end
  end

  def read_input
    ARGF.each_line do |line|
      line.chomp!
      yield line
    end
  end

end
