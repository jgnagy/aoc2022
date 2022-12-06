def gather_elves(file_name = "test_input.txt")
  elves = [] of Int32
  buffer = [] of String
  File.each_line(file_name) do |line|
    if line.empty?
      elves << buffer.map { |x| x.to_i }.sum
      buffer.clear
    else
      buffer << line
    end
  end

  elves
end

puts "Part 1: #{gather_elves.max?}"
puts "Part 2: #{gather_elves.sort.last(3).sum}"
