#!/usr/bin/env ruby

def gather_elves(file_name = "test_input.txt")
  elves = []
  buffer = []
  File.foreach(file_name) do |line|
    if line == "\n"
      elves << buffer.map(&:to_i).sum
      buffer = []
    else
      buffer << line.chomp
    end
  end

  elves
end

puts "Part 1: #{gather_elves.max}"
puts "Part 2: #{gather_elves.max(3).sum}"
