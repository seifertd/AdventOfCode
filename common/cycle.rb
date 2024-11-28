# Class that can iterate over elements in an array 
# over and over
class Cycle
  attr_accessor :counter
  def initialize(array)
    @array = array
    reset
  end

  def reset
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
