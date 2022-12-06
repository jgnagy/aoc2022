#!/usr/bin/env ruby

@letters = ("a".."z").to_a + ("A".."Z").to_a

values = []
File.foreach("test_input.txt") do |line|
  length = line.length
  first_rucksack = line[..(length / 2)].chars
  second_rucksack = line[(length / 2)..].chars

  values << @letters.find_index(first_rucksack.intersection(second_rucksack).first) + 1
end

puts values.sum

badges = []
File.foreach("test_input.txt").each_slice(3) do |batch|
  badge = batch.map(&:chars).reduce { |a,b| a.intersection(b) }.first
  badges << @letters.find_index(badge) + 1
end

puts badges.sum
