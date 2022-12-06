STACKS = {
  "1" => %w[N Z],
  "2" => %w[D C M],
  "3" => %w[P]
}

def move_crates(stacks, count, src, dst)
  stacks[src].shift(count).each do |crate|
    stacks[dst].insert(0, crate)
  end
end

part_1_stacks = STACKS.clone
File.each_line("test_input.txt") do |line|
  inst = line.chomp.split(" ")
  move_crates(part_1_stacks, inst[1].to_i, inst[3], inst[5])
end

puts "Part 1: #{part_1_stacks.values.map { |s| s.first }.join}"

def move_crates_p2(stacks, count, src, dst)
  stacks[src].shift(count).reverse.each do |crate|
    stacks[dst].insert(0, crate)
  end
end

part_2_stacks = STACKS.clone
File.each_line("test_input.txt") do |line|
  inst = line.chomp.split(" ")
  move_crates_p2(part_2_stacks, inst[1].to_i, inst[3], inst[5])
end

puts "Part 2: #{part_2_stacks.values.map { |s| s.first }.join}"
