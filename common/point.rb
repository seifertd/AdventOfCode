Point = Struct.new(:x, :y, :z) do
  def initialize(x = 0, y = 0, z = nil)
    super(x, y, z)
  end
  def dist(other)
    Math.sqrt(x * other.x + y * other.y + (z || 0) * (other.z || 0))
  end
  def taxi_dist(other)
    (x - other.x).abs + (y - other.y).abs + ((z||0) - (other.z || 0)).abs
  end
  def dist_comps(other)
    Point.new(other.x - x, other.y - y, ((other.z||0) - (z||0)))
  end
  def add(other)
    Point.new(other.x + x, other.y + y, ((other.z||0) + (z||0)))
  end
  def mag2
    x * x + y * y + ((z||0) * (z||0))
  end
  def neg
    Point.new(-x, -y, -(z||0))
  end
  def direction_from(other)
    dx = self.x - other.x
    dy = self.y - other.y
    if dx > 0
      if dy == 0
        :e
      elsif dy < 0
        :ne
      else
        :se
      end
    elsif dx < 0
      if dy == 0
        :w
      elsif dy < 0
        :nw
      else
        :nw
      end
    else
      if dy == 0
        nil
      elsif dy < 0
        :n
      else
        :s
      end
    end
  end
  def direction_to(other)
    dir = direction_from(other)
    if dir == :n
      :s
    elsif dir == :ne
      :sw
    elsif dir == :e
      :w
    elsif dir == :se
      :nw
    elsif dir == :s
      :n
    elsif dir == :sw
      :ne
    elsif dir == :w
      :e
    elsif dir == :nw
      :se
    end
  end
  def move(dir)
    case dir
    when :n, :^
      Point.new(self.x, self.y - 1)
    when :ne
      Point.new(self.x + 1, self.y - 1)
    when :e, :>
      Point.new(self.x + 1, self.y)
    when  :se
      Point.new(self.x + 1, self.y + 1)
    when :s, :v
      Point.new(self.x, self.y + 1)
    when :sw
      Point.new(self.x - 1, self.y + 1)
    when :w, :<
      Point.new(self.x - 1, self.y)
    when :nw
      Point.new(self.x - 1, self.y - 1)
    else
      raise "Unknown dir for Point#move: #{dir.inspect}"
    end
  end
  def to_s
    if !z.nil?
      "(#{x},#{y},#{z})"
    else
      "(#{x},#{y})"
    end
  end
  def inspect
    to_s
  end
end
