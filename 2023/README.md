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
* Day 9: easy
* Day 10: Includes an ascii art visualization of the map and what squares are inside and outside
  of the cycle.
* Day 12: Could not solve Day 2 without cheating.  Got Day 2 solution that worked for the sample input
  but took 40 minutes to run. Real input was not going to work on this.
  Thanks https://old.reddit.com/user/damaltor1 for the help and tips
  here: https://old.reddit.com/r/adventofcode/comments/18ghux0/2023\_day\_12\_no\_idea\_how\_to\_start\_with\_this\_puzzle/
* Day 13: Seemed trivial, but took a long time to figure out that 1) The solutions after applying a smudge really
  had to be different from the pre-smudge solutions and 2) Many of the maps have more than one solution and there
  is an unstated assumption that in part 1, you use the first available solution, but in part 2, you have to
  skip that one and try to find the next ... who knows, there could be N solutions in a map.  This problem
  sucked.
* Day 14: Mostly easy. Day 2 solution hinges on knowing you can never brute force 1 billion iterations of the
  platform tilting, so there has to be a cycle. Find it and the offset it starts at, then mod the 1 billion minus
  the offset by the cycle length add the offset back and replay that many tilts to get the answer.
* Day 16: Got stuck shortly on part 2 because part 1 was mutating the parsed cave data. Had to make sure 
  I copied the cave after parsing it for use as input inot part 1 and part 2.
* Day 18: Part 1 can be simulated. Part 2 can't be using the normal x,y grid. Sparse grids?
