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
* Day 2
  * Part 1 pretty easy to calculate diffs between consecutive pairs and
    eliminate any without all positive or negative diffs with absolute
    value <= 3
  * Part 2 just a brute force remove each element in turn and re-validate
* Day 3
  * regex captures for part1
  * part2 regex scanning with a small state machine
* Day 5
  * Both parts just grid coordinate manipulation
* Day 6
  * part 1 very easy
  * part 2 confoundingly hard. Had to get a hint from my folks at work, but
    once found, was again easy. Hardest concept to understand was that you don't
    have to find the loops while running the initial solution. All you have
    to do is record all unique positions and directions you ever hit on the
    original run, then put a block in front of each and rerun. Bugs abounded:
    you have to make sure not to put a block in a wall or on an existing block
* Day 7
  * just build up a tree of all possible results, count the ones that produce
    the desired answer
  * same as part 1 with one more "operator"
* Day 8 
  * Each part the same problem, but slightly different rules
* Day 9
  * I produced pretty convoluted code made even worse by combining part1 and part2
    solutions into the same implementation, but with part 1 or 2 conditionals everywhere.
    I am a software engineer, der!
* Day 10
  * Code written for Part 1 had all the data needed for Part 2, so part 2
    was finished about 2 minutes after part 1
* Day 11
  * Brute forced part 1 and said to myself "This won't scale...".
  * Part 2: Had to make it scale using pretty easy memoization and pruning techniques
* Day 12
  * Part 1 was a challenge, but after implementing a flood fill algo and realizing the
    perimeter was a function of the number of foreign blocks touching the block in the
    flooded region, was pretty simple
  * Part 2 took me over a week. Had to think about it a million ways, went down many
    blank alleys, but then I read an article about determining if a region
    is enclosed by flooding the bounding box + 1 block and finding all non flooded
    blocks in the bound box. These are the holes. Buggy at first because I assumed
    each region could only have 1 hole. Hah hah AoC gods. Lots of debugging with
    hand crafted example inputs.
* Day 13
  * Took forever to generate solving functions because 1) My algebra sux these days and
    2) I had used ints as the types of all the variables instead of floats. After switching
    to floats, and rounding only when needed for the final value (no rounding of intermediate
    values, Sir) both parts were easy
* Day 14
  * Part 1 very easy, just a bunch of modulo math and then being careful to identify
    the quadrants correctly for the gps score calculation
  * Part 2: At first I thought this was a lcm problem, but was quickly disabused of that
    when I saw that the grid would only repeat after 6 * 10^(some big ass number) iterations.
    AoC told me that answer was "too big" ... lol. I then wrote a console visualization
    and let it run for 10 minutes before I got bored (about 1000 iterations). I had to
    cheat by looking on Reddit and seeing what the pattern looked like. It then became very
    obvious if I just detected runs of some arbitrary number of blocks in a row either
    horizontally or vertically, we'd have found the easter egg. I chose 10 vertical blocks
    and was able to find the easter egg in 7 or 8 thousand iterations (which was extremely
    fast so long as I wasn't drawing state every iteration on the console)
* Day 15
  * Part 1 was very easy
  * Part 2 was diabolical. I used flood fill to find all regions of vertically connected boxes, then
    moved them up or down as a group (left or right movement was the same as part 1). First
    problem was over interpreting the stupid "distance to the nearest edge" description in the
    problem writeup. I implemented a calculation of distance to closest edge of the map when
    the writeup meant edge of box closest to left edge of the map. Furthermore, I effed up
    even this, but the bug didn't manifest itself in the sample. Furthermore, I introduced
    a bug where I was only testing the top or bottom-most boxes (depending on direction of
    the move) for ability to move the group. Only figured out this bug existed by counting
    numbers of objects in the map at each iteration and breaking when the counts changed.
* Day 16
  * Part 1 was A* all the way, took a bit to get the g_score function correct. But I was
    able to utilize my AStar module from last year.
  * Part 2 was also just A*, but I had to add the ability for it to track all equivalent
    paths leading to the goal. But now I have this in my toolbox.
* Day 17
  * Part 1 easy, part 2 not possible without me cheating
* Day 18
  * More astar utilization for both parts
* Day 19
  * A change from A*. Key to solving this one was not trying to generate the actual towel
    arrangements, but rather just count possible ones. I took several blind alleys on this
    one before finding the pretty simple solution that involves memoizing how many good towel
    arrangements you can get from your list of patterns for a specific design, and making sure
    you memoize as you match. The real input results in a ridiculous number of possible
    arrangements for each design.
* Day 20
  * Part 1: Back to A*. My first try at part1 involved running A* many times, which worked for the 
    sample input, but failed miserably on the real input. I think it would have taken several
    hours for my first try to grind through running A* for each possible cheat. After scratching
    my head a bit, I looked at the actual input file and noted there is only 1 really windy
    corridor from start to finish and A* probably is not needed for it. So I optimized to
    generate the non cheat path, determine the distance to the finish point at every step,
    then try cheats at every step and use the memoized distances to quickly calulate the
    new distance for the cheated path.
  * Part 2: Gah, have to expand part1 a bit, but should be easy (he says at 2am)
    It was easy. Day 1 code could be cleaned up a bit to use technique in part2.
