def process_commands(file = "test_input.txt")
  directories = {}
  pwd = ""
  File.foreach(file) do |line|
    case line
    when /^\$ cd \/$/
      pwd = "/"
      directories["/"] ||= []
    when /^\$ cd ..$/
      pwd = pwd.split("/")[0..-2].join("/")
    when /^\$ cd/
      pwd = proper_dirname(pwd, /^\$ cd (.+)$/.match(line)[1])
    when /^dir/
      directory_name = /^dir (.+)$/.match(line)[1]
      full_path = proper_dirname(pwd, directory_name)
      directories[full_path] = []
    when /^[0-9]+/
      file_size = /^([0-9]+)\s(.+)/.match(line)[1]
      directories[pwd] << file_size.to_i
    end
  end
  directories
end

def proper_dirname(parent, name)
  parent =~ %r{/$} ? parent + name : "#{parent}/#{name}"
end

def process_directories(list)
  list.keys.map do |dir|
    sub_sizes = list.keys.filter_map { |d| list[d] if d.start_with?(dir) }.map(&:sum)
    { name: dir, size: sub_sizes.sum }
  end
end

def missing_free_space(dirs, required: 30_000_000, capacity: 70_000_000)
  used = dirs.select { |d| d[:name] == "/" }.first[:size]
  free = capacity - used
  required - free
end

def dir_to_delete(dirs, missing)
  dirs.select { |d| d[:size] >= missing }.min_by { |d| d[:size] }
end

processed_directories = process_directories(process_commands("input.txt"))

# Part 1
puts "Part 1: #{processed_directories.filter_map { |d| d[:size] if d[:size] <= 100_000 }.sum}"

# Part 2
missing = missing_free_space(processed_directories)
puts "Part 2: #{dir_to_delete(processed_directories, missing)[:size]}"
