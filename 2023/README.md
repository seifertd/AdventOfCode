Advent of Code 2023
============================

My solutions in Ruby to the 2023 Advent of Code

Howto
---------
In general, run a solution as

```console
ruby foo.rb input.txt
```

Both parts will be run.

Common code can be found in the `common` directory.

Notes, Blunders and Victories
--------------------------------

* Day 3: Took a while because I forgot to strip newlines off the input and thus counted as a part number
  any number at the end of the line, even if it wasn't otherwise next to a special character
* Day 5: Part 2 took a while because I forgot the consider the case where the input range covered
  the mapping range.  I had handled the other cases: where the mapping range covers the input range,
  where they overlap and where they don't intersect. After writing things down on paper, was able to
  finally get an implementation that worked.
* Days 6 and 7: kind of boring ...
* Day 8: Part 2: Implemented the brute force method and realized quickly that it was going to take
  forever. I then actually counted the number of starting nodes in my input and there were only 5,
  so I realized this was going to be "find the lowest common multiple of a bunch of integers" problem.
  I repurposed part1 to work with either a end node or ends with Z, found how many steps each of the
  5 starting nodes would take to get to a node that ended in Z, then found the lcm of those 5 largish
  numbers. Ruby has a convenient Integer.lcm(other) method for this.
