Advent of Code 2025 solutions in ruby. If you don't want your try
at a solution to be spoiled, don't look at this code.

All code can be run as follows:

```bash
# Run the Part 1 code against the sample input
ruby 01.rb part1 sample.txt
# Run part 2 solution against the sample input
ruby 01.rb part2 sample.txt
```

Per the request of the AoC authors, I will not be publishing
my inputs for the puzzles.

Many of the solutions use utility code found in the `common`
directory that is at the same level as the year directories.
Be sure when you run such solutions that the common directory
can be found relative to the code correctly. If you checkout
this entire git repo, you will create a proper strucure

```
├── 2025
│   ├── 01
│   ├── 02
│   ├── 03
...
│   ├── 21
│   ├── 22
│   ├── 23
│   ├── 24
│   └── 25
└── common
```

Some solutions support detailed DEBUG output, but be careful, this
can spew tons of output if run against the full input

```bash
DEBUG=true ruby 06.rb part1 sample.txt
```

* Day 1
  * Part 1 - very easy modulo math implementation
  * Part 2 - I gave up trying to do this elegantly and just brute
    forced it. 
* Day 2
  * Part 1 - ignored id's with odd numbers of digits, then split the
    ones with even numbers of digits into two halves by dividing
    by 10 ^ (numDigits / 2) and then doing mod 10 ^ (numDigits / 2).
    If these two numbers are the same, the id is invalid.
  * Part 2 - Another brute force solution by taking the number as 
    a string, splitting it into equal sized chunks, then if chunks two
    through N are the same as chunk 1, the id is invalid
* Day 3
  * Part 1 - extremely easy
  * Part 2 - devilishly difficult
