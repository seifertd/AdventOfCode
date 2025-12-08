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
* Day 4 - 20 minutes total on this easy day
  * Part 1 - ability to reuse common code from previous years, like the
    Point class I wrote makes these types of problems a breeze
  * Part 2 - true brute force and consumption of tons of RAM, but that is cheap!
    To see console animation of roll removal, provide ANIMATE=true when running
    the solution:
    ```
    ```
    ANIMATE=true ruby 04.rb sample.txt
    ```
    For the full input, you will need to make your font really small
* Day 5
  * Part 1 - despite bugs in the code I wrote to merge ranges, got 
    the right answer anyway
  * Part 2 - Bugs caused me to get the wrong answer on the real input,
    but raising an exception on detecting a overlap while iterating
    all the *supposedly* merged ranges revealed the bug. I had not
    considered all the ways the ranges could overlap with other ranges.
    - 1: 
      ```
      <------->
         <---------->
      ```
    - 2:
      ```
      <--------->
             <------>
      ```
    - 3:
      ```
      <--------->
         <--->
      ```
    - 4:
      ```
           <---->
      <------------>
      ```
    I forgot to account for the last one :(
* Day 6
  * Part 1 - Simple string splitting to get all the operands as integers, then
    ruby's inject function on this array using the operator turned into a symbol
    makes quick work of this problem
  * Part 2 - Same as the first, but collecting all the operands as integers
    is a bit harder. I noticed that the operator always appears in the first column 
    of each problem. From there you have to collect all the numbers in that
    and all columns up to the next operand, throwing away the empty column, then
    perform the operation and keep the running total. The whole right to left 
    rigamarole was a distraction. Just do it left to right. Addition is transitive.
* Day 7
  * Part 1 - easy enough to just keep track of what column in the grid had a problem
    in it and figure out if it was going to hit a splitter when it tried to overlap
    to the next row down. A simple Set of column indexes where there was a problem
    made short work of this one
  * Part 2 - A simple change of the Set to an Array and allowing it to accumulate
    duplicate column indexes worked for the sample, but of course did not scale for
    the real input. Changing the Array to hold the count of beams in that column answer
    we iterated down the grid instead of trying to make it hold all beam column indexes
    was the trick to making this run very quickly even on the real input.
* Day 8
  * Part 1 - struggled a bit trying to get deletes of ruby Sets from a containing
    Set to work. Also had to fix the `dist` method of my Point class. I gave up
    on the containing Set and changed the it to an Array. From there the
    approach I took of calculating all pairs of points and their distances, then sort
    the list of pairs by distance, then iterate over the first N (10 for the sample,
    1000 for the real input) and add pairs of points to sets (circuits), merging sets
    when common points are encountered.
  * Part 2 - Just changed to keep adding points until we are left with one set of
    points (1 circuit) containing all the points.
