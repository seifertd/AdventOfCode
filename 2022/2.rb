plays = {
  "A" => "Rock",
  "X" => "Rock",
  "B" => "Paper",
  "Y" => "Paper",
  "C" => "Scissors",
  "Z" => "Scissors"
}
scores = {
  "Rock" => 1,
  "Paper" => 2,
  "Scissors" => 3
}

outcomes = {
  "X" => "lose",
  "Y" => "draw",
  "Z" => "win"
}

winlose = {
  "Rock" => ["Scissors", "Paper"],
  "Paper" => ["Rock", "Scissors"],
  "Scissors" => ["Paper", "Rock"]
}

loseplay =
total_score = 0

ARGF.each_line do |line|
  line.chomp!
  opp, me = line.split(" ")
  opp = plays[opp]
  outcome = outcomes[me]
  round_score = 0
  if outcome == "win"
    round_score = 6
    me = winlose[opp].last
  elsif outcome == "draw"
    round_score = 3
    me = opp
  else
    round_score = 0
    me = winlose[opp].first
  end
  round_score += scores[me]
  puts "OPP: #{opp} ME: #{me} OUTCOME: #{outcome} round_score: #{round_score}"
  total_score += round_score
=begin
  me = plays[me]
  puts "OPP: #{opp} ME: #{me}"
  round_score = scores[me]
  if opp == me
    round_score += 3
  elsif me == "Scissors" && opp == "Paper" ||
     me == "Rock" && opp == "Scissors" ||
     me == "Paper" && opp == "Rock"
    round_score += 6
  end
  puts "SCORE: #{round_score}"
  total_score += round_score
=end
end

puts "Total: #{total_score}"

