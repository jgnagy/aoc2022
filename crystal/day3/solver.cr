LETTERS = ("a".."z").to_a + ("A".."Z").to_a

def find_values(file = "test_input.txt")
  values = [] of Int32
  File.each_line(file) do |line|
    length = line.chars.size
    first_rucksack = line.chars[..((length / 2).to_i - 1)]
    second_rucksack = line.chars[(length / 2).to_i..]

    index = LETTERS.index((first_rucksack & second_rucksack).first.to_s) || 0
    values << index + 1
  end
  values
end

puts find_values.sum

def fine_badges(file = "test_input.txt")
  badges = [] of Int32
  File.read_lines(file).each_slice(3) do |batch|
    badge = batch.map { |x| x.chars }.reduce { |a,b| a & b }.first
    index = LETTERS.index(badge.to_s) || 0
    badges << index + 1
  end
  badges
end

puts fine_badges.sum
