Day 17
------

Part 1
------

Will use A* for this.

First attempts didn't account for the fact that we need to not only
track minimum heat per location, but per location per trail used to 
arrive.

My effort solved my input in 1 hour 23 minutes :( This probably won't
scale to part 2 ...

Part 2
------

Part 2 only took 2 hours.


I am obviously missing the real way to solve this


```
➜ DEBUG=astar,part1,part2 ruby 17.rb sample.txt
Start: (0,0) Finish: (12,12)
CityBlock: rows=13 cols=13
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
ASTAR: steps: 0 queue size: 2, best path terminus: (0,0)
ASTAR: steps: 1000 queue size: 329, best path terminus: (5,4)
ASTAR: steps: 2000 queue size: 438, best path terminus: (2,12)
ASTAR: steps: 3000 queue size: 335, best path terminus: (9,4)
Best Path:
[(0,0), (1,0), (2,0), (2,1), (3,1), (4,1), (5,1), (5,0), (6,0), (7,0), (8,0), (8,1), (9,1), (9,2), (10,2), (10,3), (10,4), (11,4), (11,5), (11,6), (11,7), (12,7), (12,8), (12,9), (12,10), (11,10), (11,11), (11,12), (12,12)]
2>>34^>>>1323
32v>>>35v>623
325524565v>54
3446585845v52
4546657867v>6
14385987984v4
44578769877v6
36378779796v>
465496798688v
456467998645v
12246868655<v
25465488877v5
43226746555v>
Heat Loss: 102
Part 1: 102
Start: (0,0):[] Finish: (12,12):[]
CityBlock: rows=13 cols=13
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
ASTAR: steps: 0 queue size: 2, best path terminus: (0,0):[]
Best Path:
[(0,0):[], (1,0):[:e, 1], (2,0):[:e, 2], (3,0):[:e, 3], (4,0):[:e, 4], (5,0):[:e, 5], (6,0):[:e, 6], (7,0):[:e, 7], (8,0):[:e, 8], (8,1):[:s, 1], (8,2):[:s, 2], (8,3):[:s, 3], (8,4):[:s, 4], (9,4):[:e, 1], (10,4):[:e, 2], (11,4):[:e, 3], (12,4):[:e, 4], (12,5):[:s, 1], (12,6):[:s, 2], (12,7):[:s, 3], (12,8):[:s, 4], (12,9):[:s, 5], (12,10):[:s, 6], (12,11):[:s, 7], (12,12):[:s, 8]]
2>>>>>>>>1323
32154535v5623
32552456v4254
34465858v5452
45466578v>>>>
143859879845v
445787698776v
363787797965v
465496798688v
456467998645v
122468686556v
254654888773v
432267465553v
Heat Loss: 94
Part 2: 94
```
