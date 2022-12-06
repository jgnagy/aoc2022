def elven_pairs(file = "input.txt")
  pairs = [] of Array(Array(Int32))

  File.each_line(file) do |line|
    elf_pair = line.chomp.split(",")
    elf_pair = elf_pair.map do |elf|
      start, finish = elf.split("-")
      (start.to_i..finish.to_i).to_a
    end
    pairs << elf_pair
  end
  pairs
end

part_1 = elven_pairs.select { |e| (e.first - e.last).empty? || (e.last - e.first).empty? }.size
puts "Part 1: #{part_1}"

part_2 = elven_pairs.select { |e| (e.first & e.last).any? }.size
puts "Part 2: #{part_2}"
