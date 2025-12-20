class Solution
  def parse
    @workflows = {}
    @ratings = []
    parsing_workflows = true
    input do |line|
      if line.empty?
        parsing_workflows = false
        next
      end
      if parsing_workflows
        name, rules = line.split("{")
        rules = rules[0..-2].split(",").map do |rule|
          cond, target = rule.split(':')
          if target.nil?
            [cond]
          else
            if cond =~ /^([^<>]+)([<>])(\d+)/
              [{rating: $1, op: $2, val: $3.to_i}, target]
            else
              raise "Condition not in RATING (<|>) NUMBER format: #{cond}"
            end
          end
        end
        debug { "Workflow: #{name} Rules: #{rules.inspect}\n" }
        @workflows[name] = rules
      else
        ratings = {}
        line[1..-2].split(",").each do |rating|
          k, v = rating.split('=')
          ratings[k] = v.to_i
        end
        debug { "Ratings: #{ratings.inspect}\n" }
        @ratings << ratings
      end
    end
    raise "no starting workflow called 'in'" unless @workflows.has_key?('in')
  end
  def eval_cond(rating, cond)
    lhs = rating[cond[:rating]]
    rhs = cond[:val]
    cond[:op] == '<' ? lhs < rhs : lhs > rhs
  end
  def part1
    parse
    sum = 0
    @ratings.each do |rating|
      visited_workflows = Set.new ['in']
      rules = @workflows['in']
      next_workflow = nil
      while true
        next_workflow = nil
        rules.each do |rule|
          if rule.size == 1
            next_workflow = rule[0]
          else
            if eval_cond(rating, rule[0])
              next_workflow = rule[1]
            end
          end
          break unless next_workflow.nil?
        end
        if next_workflow.nil?
         raise "Could get next workflow for rules: #{rules.inspect}, rating: #{rating.inspect}" if next_workflow.nil?
        end
        break if ['A', 'R'].include?(next_workflow)
        if visited_workflows.include?(next_workflow)
          raise "CIRCULAR EVAL FOR RATING: #{rating.inspect}"
        end
        rules = @workflows[next_workflow]
      end
      if next_workflow == 'A'
        sum += rating.values.sum
      elsif next_workflow != 'R'
        raise "Got unexpected stopping condition: #{next_workflow}"
      end
    end
    sum
  end
  def dist_rule(cond, ratings)
    truthy = Marshal.load(Marshal.dump(ratings))
    falsey = Marshal.load(Marshal.dump(ratings))
    rating = cond[:rating]
    range = ratings[rating]
    rhs = cond[:val]
    if cond[:op] == '<'
      if range[0] < rhs && range[1] < rhs
        falsey = nil
      elsif range[0] < rhs && range[1] >= rhs
        truthy[rating][1] = rhs - 1
        falsey[rating][0] = rhs
      elsif range[0] >= rhs && range[1] >= rhs
        truthy = nil
      end
    else
      if range[0] > rhs && range[1] > rhs
        falsey = nil
      elsif range[0] <= rhs && range[1] > rhs
        truthy[rating][0] = rhs + 1
        falsey[rating][1] = rhs
      elsif range[0] <= rhs && range[1] <= rhs
        truthy = nil
      end
    end
    [truthy, falsey]
  end

  def dist_workflow(rules, ratings, queue, results)
    ratings = Marshal.load(Marshal.dump(ratings))
    rules.each do |rule|
      debug { "  -> Rule: #{rule.inspect}\n" }
      if rule.size == 1
        target = rule[0]
        if target == 'A'
          results << ratings
          break
        elsif target == 'R'
          # todo: do anything here?
          break
        else
          debug { "     -> Ratings: #{ratings.inspect}\n" }
          queue << [@workflows[rule[0]] || [rule[0]], ratings]
        end
      else
        truthy, falsey = dist_rule(rule[0], ratings)
        debug { "     -> T: #{truthy} F: #{falsey} Target: #{rule[1]}\n" }
        if !truthy.nil?
          target = rule[1]
          queue << [@workflows[target] || [target], truthy]
        end
        if !falsey.nil?
          ratings = falsey
        else
          break
        end
      end
    end
  end
  def part2
    parse
    ratings = {'x' => [1,4000], 'm' => [1,4000], 'a' => [1,4000], 's' => [1,4000]}
    queue = [[@workflows['in'], ratings]]
    results = []
    while !queue.empty?
      rules, ratings = queue.pop
      debug { "Working on workflow: #{rules} ratings: #{ratings}\n" }
      dist_workflow(rules, ratings, queue, results)
    end
    combos = 0
    results.each do |r|
      x1 = r['x'][0]
      x2 = r['x'][1]
      m1 = r['m'][0]
      m2 = r['m'][1]
      a1 = r['a'][0]
      a2 = r['a'][1]
      s1 = r['s'][0]
      s2 = r['s'][1]
      prod = (x2-x1+1) * (m2-m1+1) * (a2-a1+1) * (s2-s1+1)
      debug { "x: %04d-%04d m: %04d-%04d a: %04d-%04d s: %04d-%04d => %d\n" % [x1,x2,m1,m2,a1,a2,s1,s2,prod] }
      combos += prod
    end
    combos
  end
  def input
    ARGF.each_line do |line|
      line.chomp!
      yield(line)
    end
  end
  def debug
    print(yield) if ENV['DEBUG']
  end
end

if __FILE__ == $0
  err = 0
  if ARGV.length == 0
    err = 1
    puts "ERROR: no arg provided"
  elsif ARGV[0] == 'part1'
    ARGV.shift
    solution = Solution.new
    puts "Part 1: #{solution.part1}"
  elsif ARGV[0] == 'part2'
    ARGV.shift
    solution = Solution.new
    puts "Part 2: #{solution.part2}"
  else
    puts "ERROR: Unknown arguments: #{ARGV.inspect}"
  end
  if err > 0
    puts "Usage: ruby #{__FILE__} [part1|part2]"
  end
end
