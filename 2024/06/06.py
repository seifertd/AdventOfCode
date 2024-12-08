arr = [x.strip() for x in open(0)]
rows, cols = len(arr), len(arr[0])
inbound = lambda i, j: 0 <= i < rows and 0 <= j < cols
for i in range(rows):
    for j in range(cols):
        if arr[i][j] == '^':
            si, sj = i, j
dy = [-1, 0, 1, 0]
dx = [0, 1, 0, -1]
def check(i, j, oi=-1, oj=-1, d=0):
    seen = {(i, j, d)}
    while True:
        i += dy[d]; j += dx[d]
        if not inbound(i, j): return seen
        if arr[i][j] == '#' or (i, j) == (oi, oj):
            i -= dy[d]; j -= dx[d]
            d = (d + 1) % 4
        if (i, j, d) in seen: return None
        seen.add((i, j, d))
print(len({(i, j) for i, j, _ in check(si, sj)}))
print(sum(not check(si, sj, oi, oj) for oi in range(rows) for oj in range(cols) if arr[oi][oj] == '.'))
