#!/usr/bin/env ruby

@old_stacks = {
  "1" => %w[N Z],
  "2" => %w[D C M],
  "3" => %w[P]
}

@stacks = {
  "1" => %w[G W L J B R T D],
  "2" => %w[C W S],
  "3" => %w[M T Z R],
  "4" => %w[V P S H C T D],
  "5" => %w[Z D L T P G],
  "6" => %w[D C Q J Z R B F],
  "7" => %w[R T F M J D B S],
  "8" => %w[M V T B R H L],
  "9" => %w[V S D P Q]
}

def move_crates(stacks, count, src, dst)
  stacks[dst].unshift(Array(stacks[src].shift(count)).reverse)
  stacks[dst].flatten!
end

part_1_stacks = Marshal.load(Marshal.dump(@stacks))
File.foreach("input.txt") do |line|
  inst = line.chomp.split(" ")
  move_crates(part_1_stacks, inst[1].to_i, inst[3], inst[5])
end

puts "Part 1: #{part_1_stacks.values.map(&:first).join}"

def move_crates_p2(stacks, count, src, dst)
  stacks[dst].unshift(Array(stacks[src].shift(count)))
  stacks[dst].flatten!
end

part_2_stacks = Marshal.load(Marshal.dump(@stacks))
File.foreach("input.txt") do |line|
  inst = line.chomp.split(" ")
  move_crates_p2(part_2_stacks, inst[1].to_i, inst[3], inst[5])
end

puts "Part 2: #{part_2_stacks.values.map(&:first).join}"
