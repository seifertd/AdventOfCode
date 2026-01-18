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
