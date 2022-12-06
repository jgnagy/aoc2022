#!/usr/bin/env ruby

def find_start(packet, count = 4)
  buffer = []
  packet.chars.each_with_index do |char, idx|
    buffer.shift if buffer.size == count
    buffer << char
    return idx + 1 if buffer.uniq.size == count
  end
end

File.foreach("input.txt") { |line| puts find_start(line) }
File.foreach("input.txt") { |line| puts find_start(line, 14) }
