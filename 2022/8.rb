#!/bin/env ruby

trees = []
ARGF.each_line.with_index do |line, row|
  line.chomp!
  tree_row = trees[row] = line.split(//).map(&:to_i)
end

rows = trees.size
cols = trees.first.size

visible = ->(r, c) {
  vis_north
}
vis_north = ->(r, c) {
  my_height = trees[r][c]
  norths = (0..(r-1)).map{|r| trees[r][c]}
  norths.all?{|h| h < my_height}
}
vis_south = ->(r, c) {
  my_height = trees[r][c]
  souths = ((r+1)..(rows-1)).map{|r| trees[r][c]}
  souths.all?{|h| h < my_height}
}
vis_east = ->(r, c) {
  my_height = trees[r][c]
  easts = ((c+1)..(cols-1)).map{|c| trees[r][c]}
  easts.all?{|h| h < my_height}
}
vis_west = ->(r, c) {
  my_height = trees[r][c]
  wests = (0..(c-1)).map{|c| trees[r][c]}
  wests.all?{|h| h < my_height}
}

visible = ->(r, c) {
  vis_north.call(r,c) || vis_south.call(r, c) || vis_east.call(r,c) || vis_west.call(r,c)
}

ss = ->(r, c) {
  score = 1
  my_height = trees[r][c]
  norths = (0..(r-1)).map{|r| trees[r][c]}.reverse
  score *= ((norths.find_index{|h| h >= my_height} || (norths.size - 1)) + 1)
  souths = ((r+1)..(rows-1)).map{|r| trees[r][c]}
  score *= ((souths.find_index{|h| h >= my_height} || (souths.size - 1)) + 1)
  easts = ((c+1)..(cols-1)).map{|c| trees[r][c]}
  score *= ((easts.find_index{|h| h >= my_height} || (easts.size - 1)) + 1)
  wests = (0..(c-1)).map{|c| trees[r][c]}.reverse
  score *= ((wests.find_index{|h| h >= my_height} || (wests.size - 1)) + 1)
  score
}

num_vis = rows * 2 + (cols - 2) * 2
max_ss = -1
(1..(rows-2)).each do |r|
  (1..(cols-2)).each do |c|
    if visible.call(r,c)
      num_vis += 1
    end
    max_ss = [max_ss, ss.call(r,c)].max
  end
end

puts "Part 1: #{num_vis} trees visible"
puts "Part 2: Max Scenic Score is #{max_ss}"
