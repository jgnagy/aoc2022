#!/usr/bin/env ruby

require "json"
require "pry"

FILENAME = "input.txt"

class PacketPair
  attr_reader :first, :second

  def initialize(first, second)
    @first = first
    @second = second
  end

  def properly_ordered?() = (first <=> second).negative?
end

class Packet
  include Comparable
  attr_accessor :parts

  def initialize(parts) = @parts = parts

  def <=>(other)
    sorting_parts = Marshal.load(Marshal.dump(parts))
    other_sorting_parts = Marshal.load(Marshal.dump(other.parts))
    return sorting_parts <=> other_sorting_parts if sorting_parts.is_a?(Integer) && other_sorting_parts.is_a?(Integer)
    return Packet.new([sorting_parts]) <=> Packet.new(other_sorting_parts) if sorting_parts.is_a?(Integer)
    return Packet.new(sorting_parts) <=> Packet.new([other_sorting_parts]) if other_sorting_parts.is_a?(Integer)

    until sorting_parts.empty?
      return 1 if other_sorting_parts.empty?

      first_part = sorting_parts.shift
      first_other = other_sorting_parts.shift

      comparison = Packet.new(first_part) <=> Packet.new(first_other)
      return comparison unless comparison.zero?
    end
    return 0 if sorting_parts.empty? && other_sorting_parts.empty?

    -1 # if parts is empty
  end
end

@input = File.read(FILENAME).split("\n\n").map do |packet_data|
  first, second = packet_data.split("\n").map do |p|
    Packet.new(JSON.parse(p))
  end
  PacketPair.new(first, second)
end

@indexes = []
@input.map(&:properly_ordered?).each_with_index { |r, idx| @indexes << idx + 1 if r }

puts "Part 1: #{@indexes.reduce(:+)}"

@input = File.read(FILENAME).split("\n").filter_map do |line|
  line.strip.empty? ? nil : Packet.new(JSON.parse(line))
end
@input += [Packet.new([[2]]), Packet.new([[6]])]

@result = @input.sort.each_with_index.select { |i| [[[2]], [[6]]].include?(i[0].parts) }.to_h.values
puts "Part 2: #{@result.map { |v| v + 1 }.reduce(&:*)}"
