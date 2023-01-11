class MyFile
  attr_reader :name
  attr_reader :parent
  attr_reader :children
  attr_accessor :size
  attr_accessor :type
  def initialize(name, type, size = 0, parent = nil)
    @name = name
    @type = type
    @size = size
    @parent = parent
    @children = []
  end
  def add_child(name, type, size = 0)
    @children << MyFile.new(name, type, size, self)
    self.increase_size(size) if size > 0
    @children.last
  end
  def increase_size(size)
    @size += size
    if @parent
      @parent.increase_size(size)
    end
  end
  def subdir(name)
    @children.find{|f| f.name == name && f.type == 'dir'}
  end
  def ls(prefix = "")
    print "#{prefix}- #{name}"
    if type == 'dir'
      puts " (dir, size=#{size})"
      @children.each {|c| c.ls(prefix + "  ") }
    else
      puts " (file, size=#{size})"
    end
  end
  def find_dirs(size = 100_000, op = :less)
    dirs = []
    if op == :less && self.size <= size
      dirs << self
    elsif op == :more && self.size >= size
      dirs << self
    end
    @children.each do |c|
      if c.type == 'dir'
        dirs.concat(c.find_dirs(size, op))
      end
    end
    return dirs
  end
end

root = MyFile.new('/', 'dir')

file = root
ARGF.each_line do |line|
  line.chomp!
  if line.start_with?("$")
    command, arg = line[2..-1].split(" ")
    #puts "command: #{command.inspect} arg: #{arg.inspect}"
    case command
    when "cd"
      #puts "CHANGE TO DIR #{arg}"
      if arg == "/"
        file = root
      elsif arg == ".."
        file = file.parent
      else
        file = file.subdir(arg)
      end
    when "ls"
      # nothing for now
    end
  else
    dirorsize, name = line.split(" ")
    if dirorsize == 'dir'
      #puts "ADDING DIR #{name} to dir #{file.name}"
      file.add_child(name, 'dir')
    else
      #puts "ADDING FILE #{name} to dir #{file.name}"
      size = dirorsize.to_i
      file.add_child(name, 'file', size)
    end
  end
end

#root.ls

PART = 2
if PART == 1
  small_dirs = root.find_dirs(100_000, :less)
  puts "Part 1: #{small_dirs.inject(0){|sum, d| sum += d.size}}"
else 
  total_space = 70_000_000
  needed = 30_000_000
  used = root.size
  left = total_space - used
  to_delete = needed - left
  raise "Already enough space: needed: #{needed} used: #{used} left: #{left} to_delete: #{to_delete}" if to_delete <= 0
  puts "needed: #{needed} used: #{used} left: #{left} to_delete: #{to_delete}"
  dirs = root.find_dirs(to_delete, :more).sort_by(&:size)
  #puts "DIRS:"
  #dirs.each do |d|
  #  puts "Dir: #{d.name} Size: #{d.size}"
  #end
  puts "Delete: #{dirs.first.name} #{dirs.first.size}"
end
