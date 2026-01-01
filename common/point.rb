Point = Struct.new(:x, :y, :z) do
  def initialize(x = 0, y = 0, z = nil)
    super(x, y, z)
  end
  def dist(other)
    Math.sqrt((x - other.x)**2 + (y - other.y)**2 + ((z || 0) - (other.z || 0))**2)
  end
  def taxi_dist(other)
    (x - other.x).abs + (y - other.y).abs + ((z||0) - (other.z || 0)).abs
  end
  def taxi_paths(target)
    paths = []
    queue = Queue.new
    queue << [self, []]
    while !queue.empty?
      p, path = queue.pop
      if p == target
        paths << path
        next
      end
      cur_dist = p.taxi_dist(target)
      ns = yield(p)
      ns.each { |n| queue << [n, path.dup.push(n.direction_from(p, false))] if n.taxi_dist(target) < cur_dist}
    end
    paths
  end
  def within_taxi(dist, rows, cols)
    points = []
    (self.y - dist).upto(self.y + dist) do |ny|
      lenx = ((self.y - ny).abs - dist).abs * 2 + 1
      (self.x-lenx/2).upto(self.x+lenx/2) do |nx|
        ok = nx >= 0 && ny >= 0 && nx < cols && ny < rows
        ok = ok && yield(nx, ny) if block_given? 
        if ok
          points << Point.new(nx, ny)
        end
      end
    end
    points
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
  def direction_from(other, compass = true)
    dx = self.x - other.x
    dy = self.y - other.y
    if dx > 0
      if dy == 0
        compass ? :e : :>
      elsif dy < 0
        :ne
      else
        :se
      end
    elsif dx < 0
      if dy == 0
        compass ? :w : :<
      elsif dy < 0
        :nw
      else
        :nw
      end
    else
      if dy == 0
        nil
      elsif dy < 0
        compass ? :n : :^
      else
        compass ? :s : :v
      end
    end
  end
  def direction_to(other)
    dir = direction_from(other)
    case dir
    when :n
      :s
    when :^
      :v
    when :ne
      :sw
    when :e
      :w
    when :>
      :<
    when :se
      :nw
    when :s
      :n
    when :v
      :^
    when :sw
      :ne
    when :w
      :e
    when :<
      :>
    when :nw
      :se
    end
  end
  def move(dir, mag = 1)
    case dir
    when :n, :^
      Point.new(self.x, self.y - mag)
    when :ne
      Point.new(self.x + mag, self.y - mag)
    when :e, :>
      Point.new(self.x + mag, self.y)
    when  :se
      Point.new(self.x + mag, self.y + mag)
    when :s, :v
      Point.new(self.x, self.y + mag)
    when :sw
      Point.new(self.x - mag, self.y + mag)
    when :w, :<
      Point.new(self.x - mag, self.y)
    when :nw
      Point.new(self.x - mag, self.y - mag)
    else
      raise "Unknown dir for Point#move: #{dir.inspect}"
    end
  end
  def traverse(to, include_first = false)
    return to_enum(__method__, to, include_first) unless block_given?
    return [].to_enum if !include_first && to == self
    dx = to.x - self.x
    dy = to.y - self.y
    if dx != 0
      x1, x2 = [self.x, to.x].sort
      x1.upto(x2) do |x|
        yield Point.new(x, to.y)
      end
    elsif dy != 0
      y1, y2 = [self.y, to.y].sort
      y1.upto(y2) do |y|
        yield Point.new(to.x, y)
      end
    else
      yield(self)
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
