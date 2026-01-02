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
* Day 12: Could not solve Part 2 without cheating.  Got Part 2 solution that worked for the sample input
  but took 40 minutes to run. Real input was not going to work on this.
  Thanks https://old.reddit.com/user/damaltor1 for the help and tips
  here: https://old.reddit.com/r/adventofcode/comments/18ghux0/2023\_day\_12\_no\_idea\_how\_to\_start\_with\_this\_puzzle/
* Day 13: Seemed trivial, but took a long time to figure out that 1) The solutions after applying a smudge really
  had to be different from the pre-smudge solutions and 2) Many of the maps have more than one solution and there
  is an unstated assumption that in part 1, you use the first available solution, but in part 2, you have to
  skip that one and try to find the next ... who knows, there could be N solutions in a map.  This problem
  sucked.
* Day 14: Mostly easy. Part 2 solution hinges on knowing you can never brute force 1 billion iterations of the
  platform tilting, so there has to be a cycle. Find it and the offset it starts at, then mod the 1 billion minus
  the offset by the cycle length add the offset back and replay that many tilts to get the answer.
* Day 16: Got stuck shortly on part 2 because part 1 was mutating the parsed cave data. Had to make sure 
  I copied the cave after parsing it for use as input into part 1 and part 2.
* Day 18: Part 1 can be simulated. Part 2 can't be using the normal x,y grid. Sparse grids?
  * 2 years later: Using ideas from later years (my implementation of a
    sparse grid, I guess) I was able to solve this one.
* Day 19 (12/2025): Part 1 - Pretty simple evaluation of rules until we
  land in the 'A' box, then keep a running total of the ratings values
  of all these. Part 2 was similar but you have to keep a queue of rule
  evaluations. Each time you evaluate a rule, you end up splitting
  the rating into 0, 1 or 2 more additional populations depending on
  how the rule condition fits into the existing range for the rating.
  Then either push another ruleset and set of ratings onto the queue,
  or move on to the next rule. Keep track of stopping points: when
  the rule conditions prunes off the ratings population entirely or 
  when a population is sent to either the 'R' or 'A' terminator. 
  Keep track of all the ratings populations that land on 'A', then
  multiply all the rating ranges together, and sum all those up. Very
  large numbers!
  * Day 20 (12/2025): Part 1 - Simple brute force simulation worked. Part 2 was a lot harder and
    I needed hints from others to be able to solve this. One thing that helped a lot to see what was
    going on was to visulize the circuit as a digraph. I wrote a shell script that turns your input
    into a `dot` file that can be fed to graphviz's dot tool to generate a png of the circuit.
    We see the circuit consists of N blobs of flip flops each of which leads
    down to rx via a conjunction module. At the bottom of this graph, we have
    the following:
    ```
      conj X (N of these) -> conj Y -> rx
    ```
    Here, we find N conj X nodes going into rx thru another conj Y. As soon as these
    are all HI, the conj Y node will send a LO to rx. Need to determine when this will happen.
    If we assume that each of conj X nodes flip to HI on a cycle (big ASSumption)
    then rx will receive a LO on the LCM of the cycle counts. But AoC is fond
    of LCM problems.
    Blind alleys and blunders: We have to determine at which button press
    each of the conj X SENT a HI to the conj Y. Keeping track of the
    last sent pulse by each conjunction doesn't work because often during a button
    press, the conj X modules will send a HI to conj Y, but then send a bunch of
    LO's to it as the queue of pulses is drained. The mistake is looking for the
    LO signals being sent to rx as the last signal of the button press. The
    instructions don't say that has to hold.
    We CAN however assume that if conj X sends a HI to conj y, the next signal
    to be processed will be from the next conj X in the graph. This is due to the
    circuit using a FIFO to process the signals and each conj X is at the same
    depth in the digraph.
 * Day 21 (12/2025) - Part 1 - Again brute force simulation. Part 2 - solution
   has eluded me, even after reading details of and lifting an implementation from
   https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
 * Day 22 (12/2025) - Part 1 - pretty easy after optimizing the code to settle all the
   blocks by using a hash of x,y coord to maximum height to move blocks down as far
   as they would go in one step. Then build up two graphs: supports and supported_by,
   which can be used to easily figure out what blocks can be removed without causing
   others to fall. Part 2 was just an extended application of using the same
   technique in part 1, but with using a queue to keep track of the chain reaction
   that can occur when you remove a block. I have in mind adding an animated simulation
   of at least the settling phase, got so far as rendering the input in simulated
   3d here: https://seifertd.github.io/AdventOfCode/2023/22/visualizer.html. You can
   open your own input.txt to see the jumble of blocks you start with.

