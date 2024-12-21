module AStar
  DEBUG = ENV['DEBUG'] && ENV['DEBUG'].include?("astar")
  # grid must implement #neighbors(point, path), #g_score(p1, p2) and #h_score(p1, p2, goal)
  def self.optimal_path(grid, start, finish, options = {all_paths: false, term_proc: nil})
    queue = [start]
    path_from = {}
    path_from[start] = [start]
    cost_to = Hash.new{|h,k| h[k] = 1e6}
    priority = Hash.new{|h,k| h[k] = 1e6}
    prev = Hash.new{|h,k| h[k] = Array.new}
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
      if options[:term_proc] && options[:term_proc].call(current, path_from[current])
        return path_from[current]
      end
      neighbors = grid.neighbors(current, path_from[current])
      for n in neighbors
        raise "NEIGHBER IS SAME AS CURRENT" if current.eql?(n)
        new_cost = cost_to[current] + grid.g_score(current, n)
        if new_cost <= cost_to[n]
          prev[n] << current
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
      end
      if DEBUG
        if steps % 1000 == 0
          puts "ASTAR: steps: #{steps} queue size: #{queue.size}, best path terminus: #{current}"
        end
        steps += 1
      end
    end
    if found
      if !options[:all_paths]
        path_from[finish]
      else
        paths = [[finish]]
        while paths.any?{|p| p.last != start}
          numpaths = paths.size
          numpaths.times do |pidx|
            path = paths[pidx]
            curr = path.last
            origpath = Marshal.load(Marshal.dump(path))
            prev[curr].each.with_index do |n, nidx|
              if nidx == 0
                path << n
              else
                newpath = Marshal.load(Marshal.dump(origpath))
                newpath << n
                paths << newpath
              end
            end
          end
        end
        paths
      end
    else
      []
    end
  end
end
