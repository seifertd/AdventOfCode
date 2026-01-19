Advent of Code 2015
============================

My solutions in Ruby to the 2015 Advent of Code

Howto
---------
In general, run a solution as

```console
ruby foo.rb [part1|part2] input.txt
```

Common code can be found in the `common` directory.

Notes, Blunders and Victories
--------------------------------

* Days 1-5: Nothing particularly difficult here.
* Day 6: Started sketching out a way to track the pixels by storing
  boxes of on pixels, then mutating the boxes in response to the
  different operations. Then I remembered that RAM is cheap and
  brute force in 2026 is the way to go. Wonder if my store a list
  of boxes approach would have been needed in 2015. I also added
  the ability to generate a PNG based on the final light state, hoping
  that it would reveal an easter egg. Unfortunately no. I wonder if
  modern Eric would have done this.
* Day 7: Two solutions, an emulator and a recursive one. The recursive
  solution is more satisfying, and I guess slightly less complex:

      --------------------------------------------------------------------------------
      File                              blank        comment           code
      --------------------------------------------------------------------------------
      07/07_emulate.rb                      1              0            114
      07/07_recursive.rb                    1              1             97
      --------------------------------------------------------------------------------
      SUM:                                  2              1            211
      --------------------------------------------------------------------------------

* Day 8: Brutally easy in Ruby using eval and the String#inspect
  method, which does all the escaping needed in the input strings
* Day 9: Few enough nodes that dfs solves both parts. Used graphviz
  to create an image of the input graph.
* Day 10: Brute force for Part 1, had to watch the video and learn
  about the look-n-say sequence's interesting elements. Messed
  about trying to start with arbitrary strings and convert substrings
  into elements as the strings evolve, but that didn't work too 
  well. Then saw that the input string itself is an element and
  the evolution code was much simpler from there.
* Day 11: Several hours mucking about with a Santa's Password
  class that implemented  26 digit bijective numeration. I fell
  into the iterate for a billion years trap implementing Part 1
  and trying to generate the next valid password on the sample
  data in the problem description. I saw that it would speed things
  up a lot to detect the illegal characters and jump to a password
  whose number was past that, but my initial tries were bad. I was
  adding powers of 26 to get past the bad password and all I had
  to do was set the bad digit to the next one and set all remaining
  digits to 'a'.
* Day 12: Easy as you care to make it. Part 1 is simple regex scan
  for digits. Part 2: parse the JSON into an object, then write some
  easy recursive code to count all the numbers.
* Day 13: Identical to Day 9, as the problem can be treated as finding
  the maximal path through a weighted graph, just with the addition
  of closing the loop at the end. Removed the redundant looping
  through each node as the starting node code as it does not matter
  where you start, the dfs will find the optimal path. Part 2 was
  just a bit of code to add a new node and set of edges to all the
  other nodes with 0 weight. Was stymied for a while in Part 2,
  because I thought we had to enter the change from part 1. Goofy
  problem statement where the graph edge weights are "change in 
  happiness" and we are not asked for the "total change in *change*
  in happiness".
* Day 14: Part 1 was probably over optimized, but both parts were
  easy to solve.
* Day 15: Initially though I was going to need some kind of
  math for this, but after thinking about combinations of integers
  that add up to 100, I realized that brute force was going to be
  ok. Part 2 just a extension of Part 1 to not count certain
  combos based on an additional calculation.
* Day 16: Part 1 pretty easy, part 2 likewise easy but you have
  to get the boolean logic right.
* Day 17: Day 15 was practice for this problem, as the solution
  was about the same. Part 2 was just adding some code to keep
  track of the minimum number of containers and how many combos
  of containers had that many.
