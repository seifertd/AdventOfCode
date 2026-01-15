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
