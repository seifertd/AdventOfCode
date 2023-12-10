Advent of Code 2023
============================

My solutions in Ruby to the 2023 Advent of Code

Howto
---------
In general, run a solution as

```console
ruby foo.rb input.txt
```

Both parts will be run

Notes, Blunders and Victories
--------------------------------

* Day 3: Took a while because I forgot to strip newlines off the input and thus counted as a part number
  any number at the end of the line, even if it wasn't otherwise next to a special character
* Day 5: Part 2 took a while because I forgot the consider the case where the input range covered
  the mapping range.  I had handled the other cases: where the mapping range covers the input range,
  where they overlap and where they don't intersect. After writing things down on paper, was able to
  finally get an implementation that worked.
