SAVE_ARGV = ARGV[0..-1]

def part1
  total = 0
  ARGF.each_line do |line|
    line.chomp!
    line.gsub! /[a-z]+/i, ''
    num = line[0].to_i * 10 + line[-1].to_i
    total += num
  end
  total
end

class Regexp
  def +(regexp)
    self.class.new("#{source}#{regexp.source}")
  end
end

def part2
  digit_words = ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine']
  total = 0
  ARGV.replace(SAVE_ARGV)
  ARGF.each_line do |line|
    line.chomp!
    puts line if ENV['DEBUG']
    tens = ones = 0
    fi = li = nil
    digit_words.each.with_index do |dw, idx|
      if wi = line.index(dw)
        if !fi || wi < fi
          tens = (idx + 1)
          fi = wi
          puts "Found First word: #{dw}, idx=#{idx}, tens=#{tens} fi=#{fi}" if ENV['DEBUG']
          break if fi == 0
        end
      end
    end
    digit_words.each.with_index do |dw, idx|
      if wi = line.rindex(dw)
        if !li || wi > li
          ones = (idx + 1)
          li = wi
          puts "Found Last word: #{dw}, idx=#{idx}, ones=#{ones} fi=#{fi} li=#{li}" if ENV['DEBUG']
        end
      end
    end
    fdi = line.index(/\d/)
    if fdi && (!fi || fdi < fi)
      fi = fdi
      tens = line[fdi].to_i
    end
    ldi = line.rindex(/\d/)
    if ldi && (!li || ldi > li)
      li = ldi
      ones = line[ldi].to_i
    end
    num = tens * 10 + ones
    puts "LINE: #{line}: TENS: #{tens} ONES: #{ones} NUM: #{num}" if ENV['DEBUG']
    total += num
  end
  total
end

puts "Part1: #{part1}"
puts "Part2: #{part2}"
