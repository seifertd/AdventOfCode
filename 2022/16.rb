require_relative "./advent_of_code"
require "rgl/topsort"
require "rgl/dijkstra"
require "rgl/traversal"
require "rgl/adjacency"
require "rgl/dot"

class Day16 < AdventOfCode
  attr_reader :valves
  class Valve
    attr_accessor :name, :flow_rate, :connections, :open
    def initialize(n, fr)
      @name = n
      @flow_rate = fr
      @open = false
    end
    def to_s
      "#{name}:#{flow_rate}"
    end
    def inspect
      to_s
    end
    def graph(valves)
      graph = RGL::DirectedAdjacencyGraph.new
      # Add the root conns first to get the diagram with root on top
      self.connections.each {|c| graph.add_edge(self, valves[c])}
      valves.each do |valve_name, valve|
        next if valve_name == self.name
        valve.connections.each do |conn|
          graph.add_edge(valve, valves[conn])
        end
      end
      #valves.each do |valve_name, valve|
      #  puts "#{valve} => #{graph.out_degree(valve)} edges"
      #end
      graph
    end
    def best_target(valves, time_left)
      graph = self.graph(valves)
      distance_map = Hash.new{|h,k| h[k] = 0}
      iter = graph.bfs_iterator(self)
      iter.attach_distance_map(distance_map)
      iter.to_a
      #puts "best target for #{self}, distances: #{distance_map.inspect}"
      potentials = {}
      valves.each do |vn, valve|
        dist = distance_map[valve]
        dist_fact = valve.connections.size > 1 ? 1 : 1
        potential = (time_left - dist + 1) * dist_fact * (valve.open ? 0 : valve.flow_rate)
        if potential > 0 && vn != self.name
          potentials[valve] = [dist, potential]
        end
      end
      #puts "POTS tl=#{time_left}: #{potentials.inspect}"
      best_valve = potentials.to_a.max_by do |valve, arr|
        arr.last
      end
      return nil if best_valve.nil?
      best_valve.flatten!
      path = graph.dijkstra_shortest_path(Hash.new{1}, self, best_valve.first)
      best_valve[2] = path
      #puts "BEST: #{best_valve.inspect}"
      # If we are going to run over a valve with a >0 flow let's figure out if it is
      # better to stop there instead
      candidates = path.find_all do |v|
        v.name != self.name && v.name != best_valve.first.name && !v.open && v.flow_rate > 0
      end
      #puts "CANDIDATE BETTERS: #{candidates.inspect}"
      better_idx = nil
      better_gain = 0
      candidates.each do |candidate|
        idx = path.find_index(candidate)
        #puts "  -> idx: #{idx}"
        gain = (path.size - idx) * candidate.flow_rate
        loss = best_valve[0].flow_rate
        #puts "  -> gain: #{gain} loss: #{loss}"
        if gain > loss
          if better_idx.nil? || gain > better_gain
            better_idx = idx
            better_gain = gain
          end
        end
      end
      if better_idx
        best_valve[0] = path[better_idx]
        best_valve[1] = better_idx + 1
        best_valve[2] = graph.dijkstra_shortest_path(Hash.new{1}, self, path[better_idx])
        #puts "BETTER: #{best_valve.inspect}  CONNECTIONS: #{self.connections}"
      end
      best_valve
    end
  end
  def initialize
    super
    @valves = {}
  end
  
  def load_data
    read_input do |line|
      line.scan(/^Valve ([^ ]+) has flow rate=(\d+);.*leads? to valves? (.+)$/) do |md|
        valve = md[0]
        flow_rate = md[1].to_i
        valve = Valve.new(valve, flow_rate)
        connections = md[2].split(", ")
        puts "Read valve #{valve}:#{connections.inspect}"
        @valves[valve.name] = valve
        valve.connections = connections
      end
    end
  end
  def run
    if @part == 1
      part1
    else
      part2
    end
  end
  def part2
    load_data
    root = @valves['AA']
    graph = root.graph(@valves)
    graph.write_to_graphic_file('png')
    time_left = 26 
    openable = @valves.values.inject(0) {|sum, v| sum += 1 if v.flow_rate > 0; sum}
    opened = 0
    total_flow_rate = 0
    total_flow = 0
    minute = 1
    human_root = root
    human_target = nil
    elephant_root = root
    elephant_target = nil
    while (time_left > 0)
      puts "== Minute #{minute} =="
      if opened >= openable
        puts "ALL OPENED, rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
        time_left -= 1
        minute += 1
        total_flow += total_flow_rate 
        next
      end
      if elephant_target.nil?
        elephant_target =  elephant_root.best_target(@valves, time_left)
        if !elephant_target.nil?
          elephant_target[2].shift # remove the first segment
          elephant_target.first.open = true
        end
        puts "ELEPHANT TARGET: #{elephant_target.inspect}"
      end
      if human_target.nil?
        human_target =  human_root.best_target(@valves, time_left)
        if !human_target.nil?
          human_target[2].shift
          human_target.first.open = true
        end
        puts "HUMAN TARGET: #{human_target.inspect}"
      end
      flow_to_add = 0
      if !elephant_target.nil?
        move_to = elephant_target[2].shift
        if move_to.nil?
          puts "Elephant turns on #{elephant_target[0]}"
          flow_to_add += elephant_target[0].flow_rate
          elephant_root = elephant_target[0]
          elephant_target = nil
          opened += 1
        else
          puts "Elephant moves to #{move_to}"
        end
      end
      if !human_target.nil?
        move_to = human_target[2].shift
        if move_to.nil?
          puts "You turn on #{human_target[0]}"
          flow_to_add += human_target[0].flow_rate
          human_root = human_target[0]
          human_target = nil
          opened += 1
        else
          puts "You move to #{move_to}"
        end
      end
      time_left -= 1
      minute += 1
      total_flow += total_flow_rate 
      total_flow_rate += flow_to_add
      puts "rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
    end
    puts "PART2: TOTAL PRESSURE RELEASED: #{total_flow}"
  end
  def part1
    load_data
    root = @valves['AA']
    graph = root.graph(@valves)
    graph.write_to_graphic_file('png')
    time_left = 30 
    openable = @valves.values.inject(0) {|sum, v| sum += 1 if v.flow_rate > 0; sum}
    opened = 0
    total_flow_rate = 0
    total_flow = 0
    minute = 1
    while (time_left > 0)
      if opened >= openable
        puts "Minute #{minute}: Wait #{root}, rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
        time_left -= 1
        minute += 1
        total_flow += total_flow_rate 
        next
      end
      best_target =  root.best_target(@valves, time_left)
      #puts "Root = #{root}, BEST: #{best_target.inspect}"
      if !best_target.nil?
        steps = best_target.last
        steps.shift # remove root
        # Move to the best valve
        steps.each do |node|
          total_flow += total_flow_rate 
          puts "Minute #{minute}: Move to #{node}, rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
          minute += 1
          time_left -= 1
          root = node
        end
        # open root
        total_flow += total_flow_rate 
        puts "Minute #{minute}: Open #{root}, rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
        total_flow_rate += root.flow_rate
        minute += 1
        time_left -= 1
        opened += 1
        root.open = true
      else
        # not worth going anywhere
        puts "Minute #{minute}: Wait #{root}, rate: #{total_flow_rate} flow: #{total_flow} opened: #{opened}/#{openable} time_left: #{time_left}"
        time_left -= 1
        minute += 1
        total_flow += total_flow_rate 
      end
    end
    puts "PART1: TOTAL PRESSURE RELEASED: #{total_flow}"
=begin
    puts "ROOT: #{@root}"
    puts "Graph is acyclic?: #{graph.acyclic?}"
    distance_map = Hash.new{|h,k| h[k] = 0}
    iter = graph.bfs_iterator(@root)
    iter.attach_distance_map(distance_map)
    iter.to_a
    @edge_weights = Hash.new do |h,k|
      dist_target = distance_map[k.last]
      sv = @root
      tv = k.last
      weight = (30 - (dist_target - 1) * 2) * tv.flow_rate
      puts "EDGE WEIGHT: #{k}: #{weight}"
      h[k] = weight
    end
    puts "DISTANCES:"
    puts distance_map.inspect
    hh = @valves['HH']
    shortest_paths = graph.dijkstra_shortest_paths(Hash.new{1},@root)
    puts shortest_paths.inspect
=end
  end
end

if __FILE__ == $PROGRAM_NAME
  solution = Day16.new
  solution.run
end

