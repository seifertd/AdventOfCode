Advent of Code 2024 solutions in ruby. All code can be run as follows:

```
# Run the Part 1 code against the sample input
ruby 01.rb part1 sample.txt
# Run the part 1 code against the full input
ruby 01.rb part1 input.txt
# Run part 2 solution
ruby 01.rb part2 input.txt

```

Some solutions support detailed DEBUG output, but be careful, this
can spew tons of output if run against the full input
```
DEBUG=true ruby 06.rb part1 sample.txt
```


* Day 1
  * Pretty stock standard sort and zip solution for part 1
  * Part 2 changes the second list to a hash
