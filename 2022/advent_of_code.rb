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
  attr_accessor :part
  def initialize
    @part = 1
    if ARGV.length > 0
      if ARGV[0].match(/^\d+$/)
        @part = ARGV.shift.to_i
      end
    end
  end

  def read_input
    ARGF.each_line do |line|
      line.chomp!
      yield line
    end
  end

end
