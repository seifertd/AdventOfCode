require './password'

pw = Password.new('ghijklmn')
puts "pw(ghijklmn) = #{pw}:#{pw.to_i}"

i = pw.to_s =~ /[oil]/
remaining = pw.to_s.length - i - 1
puts "bad digit at: #{i} remaining: #{remaining} len: #{pw.to_s.length}"
s = Password.new(pw.to_s[0..i] + 'a' * remaining) 
puts "next num: #{s}"
