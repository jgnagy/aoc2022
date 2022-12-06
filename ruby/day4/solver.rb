#!/usr/bin/env ruby

count = 0
File.foreach("input.txt") do |line|
  elf_pair = line.chomp.split(",")
  elf_pair = elf_pair.map do |elf|
    start, finish = elf.split("-")
    (start..finish).to_a
  end
  count += 1 if (elf_pair.first - elf_pair.last).empty? || (elf_pair.last - elf_pair.first).empty?
end

puts count


count = 0
File.foreach("input.txt") do |line|
  elf_pair = line.chomp.split(",")
  elf_pair = elf_pair.map do |elf|
    start, finish = elf.split("-")
    (start..finish).to_a
  end
  count += 1 if elf_pair.first.intersect?(elf_pair.last)
end

puts count
