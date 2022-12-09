#!/usr/bin/env ruby

class Rope
  attr_accessor :head, :knots, :tail

  def initialize(additional_knots: 0)
    @knots = []
    @head = Knot.new(head: nil, rope: self)
    @knots << @head
    additional_knots.times do
      @knots << Knot.new(head: @knots.last, rope: self)
    end
    @tail = Knot.new(head: @knots.last, rope: self)
    @knots << @tail
  end

  def move_head(direction, count)
    count.times do
      case direction
      when "U"
        head.y += 1
      when "D"
        head.y -= 1
      when "L"
        head.x -= 1
      when "R"
        head.x += 1
      end
      head.visited_positions << head.position
      move_knots
    end
  end

  def move_knots
    @knots[1..-1].each do |knot|
      new_position = [knot.x.dup, knot.y.dup]
      next if knot.position == knot.head.position
      next unless (knot.x - knot.head.x).abs > 1 || (knot.y - knot.head.y).abs > 1

      new_position[0] -= 1 if knot.x > knot.head.x
      new_position[0] += 1 if knot.head.x > knot.x
      new_position[1] -= 1 if knot.y > knot.head.y
      new_position[1] += 1 if knot.head.y > knot.y

      knot.x, knot.y = new_position
      knot.visited_positions << new_position
    end
  end
end

class Knot
  attr_accessor :head, :rope, :x, :y, :visited_positions

  def initialize(head:, rope:)
    @head = head
    @rope = rope
    @x = 0
    @y = 0
    @visited_positions = [[0, 0]]
  end

  def head?() = @head.present?
  def tail?() = rope.knots.last.id == id
  def position() = [x, y]
end

def solve(rope, file = "input.txt")
  File.foreach(file) do |line|
    direction, count = line.strip.split(" ")
    rope.move_head(direction, count.to_i)
  end
  rope
end

@p1_rope = Rope.new
solve(@p1_rope)
puts "Part 1: #{@p1_rope.tail.visited_positions.uniq.size}"

@p2_rope = Rope.new(additional_knots: 8)
solve(@p2_rope)
puts "Part 2: #{@p2_rope.tail.visited_positions.uniq.size}"
