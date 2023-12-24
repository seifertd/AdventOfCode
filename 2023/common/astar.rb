module AStar
  # grid must implement #neighbors(point, path), #g_score(p1, p2) and #f_score(p1, p2, goal)
  def self.optimal_path(grid, start, finish)
    queue = [start]
    path_from = {}
    path_from[start] = [start]
    cost_to = Hash.new{|h,k| h[k] = 1e6}
    priority = Hash.new{|h,k| h[k] = 1e6}
    cost_to[start] = 0
    found = false
    steps = 0
    while queue.size > 0
      #current = queue.min{|a,b| priority[a] <=> priority[b]}
      current = queue.shift
      if current.x == finish.x && current.y == finish.y
        finish = current
        found = true
        break
      end
      neighbors = grid.neighbors(current, path_from[current].last(4))
      for n in neighbors
        raise "NEIGHBER IS SAME AS CURRENT" if current.eql?(n)
        new_cost = cost_to[current] + grid.g_score(current, n)
        if new_cost < cost_to[n]
          cost_to[n] = new_cost
          priority[n] = new_cost + grid.h_score(current, n, finish)
          path_from[n] = path_from[current] + [n]
          q_idx = 0
          while true
            if q_idx >= queue.size - 1
              queue << n
              break
            end
            if priority[queue[q_idx]] > priority[n]
              queue.insert(q_idx, n)
              break
            end
            q_idx += 1
          end
        end
      end
      if steps % 1000 == 0
        puts "ASTAR: steps: #{steps} queue size: #{queue.size}, best path terminus: #{current}"
      end
      steps += 1
    end
    if found
      path_from[finish]
    else
      []
    end
  end
end
