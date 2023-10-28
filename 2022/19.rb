require_relative "./advent_of_code"
require 'parallel'

class Day19 < AdventOfCode
  class Blueprint
    attr_accessor :number, :costs, :robot_limits
    def initialize(num, ore_cost_ore, clay_cost_ore, 
                   obs_cost_ore, obs_cost_clay,
                   geo_cost_ore, geo_cost_obs)
      @number = num
      @costs = [
        [ore_cost_ore, 0, 0],
        [clay_cost_ore, 0, 0],
        [obs_cost_ore, obs_cost_clay, 0],
        [geo_cost_ore, 0, geo_cost_obs]
      ]
      @robot_limits = [
        [ore_cost_ore, clay_cost_ore, obs_cost_ore, geo_cost_ore].max,
        obs_cost_clay,
        geo_cost_obs
      ]
    end
  end
  class State
    attr_accessor :timer, :inventory, :bots, :geodes
    def initialize(timer, inv, bots, geodes)
      @timer = timer
      @inventory = inv
      @bots = bots
      @geodes = geodes
    end
  end
  def read_blueprints
    @blueprints = []
    read_input do |line|
      nums = line.scan(/\d+/).map(&:to_i)
      @blueprints << Blueprint.new(*nums)
    end
  end
  def initial_state(timer) 
    State.new(timer, [0,0,0], [1,0,0], 0)
  end
  def can_make(state, bp, type)
    costs = bp.costs[type]
    idx = -1 
    costs.all? {|c| idx += 1; c <= state.inventory[idx] }
  end
  def make_robot(state, bp, type)
    new_state = State.new(
      state.timer,
      state.inventory.dup,
      state.bots.dup,
      state.geodes
    )
    #puts "Make robot: #{new_state.inspect}"
    while (!can_make(new_state, bp, type) && 1 < new_state.timer)
      new_state.inventory[0] = new_state.inventory[0] + new_state.bots[0]
      new_state.inventory[1] = new_state.inventory[1] + new_state.bots[1]
      new_state.inventory[2] = new_state.inventory[2] + new_state.bots[2]
      new_state.timer -= 1
    end
    new_state.timer -= 1
    costs = bp.costs[type]
    new_state.inventory.map!.with_index { |i, idx| i - costs[idx] + new_state.bots[idx] }
    if type == 3
      new_state.geodes += new_state.timer
    else
      new_state.bots[type] += 1
    end
    new_state
  end
  def find_max_geodes(state, bp, limits)
    if state.timer == 1
      return state.geodes
    end
    #puts "Timer: #{state.timer}"
    best = state.geodes
    0.upto(3) do |type|
      #puts "best: #{best} type: #{type} limits[type]: #{limits[type]} robot_limits: #{bp.robot_limits.inspect} bots: #{state.bots.inspect}"
      if state.timer < limits[type] ||
          (type != 3 && bp.robot_limits[type] < state.bots[type]) ||
          (type == 0 && state.bots[1] > 1) ||
          (type == 2 && state.bots[1] == 0) ||
          (type == 3 && state.bots[2] == 0)
        #puts "  -> skipped"
        next
      end
      next_state = make_robot(state, bp, type)
      #puts "Next state: #{next_state.inspect}"
      if next_state.timer == 0
        #puts "next state timer is 0, skipped"
        next
      end
      score = find_max_geodes(next_state, bp, limits)
      best = [best, score].max
    end
    best
  end
  def part2
    read_blueprints
    puts "Read #{@blueprints.size} blueprints"
    total = 1
    @blueprints[0..2].each do |bp|
      max_geodes = find_max_geodes(initial_state(32), bp, [22,10,6,0])
      puts "Max geodes for #{bp.number} = #{max_geodes}"
      total *= max_geodes
    end
    puts "Part 2: #{total}"
  end

  def part1
    read_blueprints
    puts "Read #{@blueprints.size} blueprints"
    total = 0
    @blueprints.each do |bp|
      max_geodes = find_max_geodes(initial_state(24), bp, [16,6,3,2])
      puts "Max geodes for #{bp.number} = #{max_geodes}"
      total += max_geodes * bp.number
    end
    puts "Part 1: #{total}"
  end
end

if __FILE__ == $PROGRAM_NAME
  solution = Day19.new
  solution.run
end

