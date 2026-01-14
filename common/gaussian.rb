module Gaussian
  EPS = 1e-6
  def self.normalize(row, ci)
    factor = row[ci]
    raise "Can't normalize row #{row} at index #{ci}, factor = 0.0" if factor.abs <= EPS
    row.map!{|v| v /= factor.to_f }
  end
  
  def self.multiply(row, factor)
    row.map!{|c| c * factor }
  end

  def self.solve(system)
    cols = system[0].length
    rows = system.length
    system.sort_by! { |r| r[0..-2].inject(0){|p,c| p*10 + c.abs}}
    raise "#cols #{cols} must be = #rows + 1 (#{system.length} + 1)" if cols != rows + 1

    # eliminate down
    system.length.times do |ri|
      row = system[ri]
      #puts "Working on row: #{row}"
      normalize(row, ri)
      #puts "Normalized: #{row}"
      system[(ri+1)..-1].each do |nrow|
        factor = nrow[0]
        #puts "before row: #{nrow}"
        nrow.map!.with_index { |c, ci| c - factor * row[ci] }
        #puts "after row: #{nrow}"
      end
    end
    #puts "afer elim down: #{system}"
    # eliminate up
    system[-2..0].each.with_index do |row, ri|
      nri = -(ri + 1)
      row_above = system[nri]
      ci = cols - ri - 2
      factor = row[ci]
      row.map!.with_index { |c, ci| c - factor * row_above[ci]}
    end
    #puts "afer elim up: #{system}"
    system
  end
end
