def find_start(packet, unique_chars = 4)
  buffer = [] of Char
  packet.chars.each_with_index do |char, idx|
    buffer.shift if buffer.size == unique_chars
    buffer << char
    return idx + 1 if buffer.uniq.size == unique_chars
  end
end

# Part 1
File.each_line("input.txt") { |line| puts find_start(line) }

# Part 2
File.each_line("input.txt") { |line| puts find_start(line, 14) }
