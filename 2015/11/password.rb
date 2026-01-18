require "stringio"
class Password
  DIGITS = ('a'..'z').to_a
  NUM_DIGITS = DIGITS.size
  GOOD_SEQS = DIGITS.each_cons(3).map(&:join)
  def initialize(val)
    if val.is_a?(Numeric)
      raise "Only positive numbers for Password: #{val.inspect}" if val < 1
      @value = val
    elsif val.is_a?(String) && val =~ /[a-z]+/
      b = 1
      @value = 0
      val.chars.reverse.each do |digit|
        @value += b * (digit.ord - 96)
        b *= NUM_DIGITS
      end
    else
      raise "Can't make an Password from object: #{val.inspect}"
    end
  end
  def method_missing(method, *args, &block)
    @value.send(method, *args, &block)
  end
  def respond_to_missing?(method, include_private = false)
    @value.respond_to?(method, include_private) || super
  end
  def invalid?
    pw = self.to_s
    !!(pw.match(/[oil]/) ||
      pw.scan(/(\w)\1/).uniq.size <= 1 ||
      !GOOD_SEQS.any?{ |s| pw.include?(s) })
  end
  def smart_inc
    pw = Password.new(self.to_i)
    # skip past all [oil] chars, starting with leftmost
    skipped = 0
    pw_s = pw.to_s
    if i = pw_s =~ /[oil]/
      char = pw_s[i]
      remaining = pw_s.length - i - 1
      npw = pw_s[0,i] + (char.ord + 1).chr + 'a' * remaining
      npw = Password.new(npw)
      skipped += (npw - pw).to_i
      pw = npw
    end
    if skipped == 0
      pw = pw + 1
      skipped = 1
    end
    pw
  end
  def ==(other)
    @value == other
  end
  def +(value)
    Password.new(@value + value)
  end
  def -(value)
    Password.new(@value - value)
  end
  def *(value)
    Password.new(@value * value)
  end
  def /(value)
    Password.new(@value / value)
  end
  def to_i
    @value
  end
  def to_s
    digits = []
    q = @value
    loop do
      q, r = q.divmod(NUM_DIGITS)
      if r == 0
        digits << DIGITS.last
        q -= 1
      else
        digits << DIGITS[r-1]
      end
      break if q == 0
    end
    digits.reverse.join
  end
  def inspect
    to_s
  end
end
