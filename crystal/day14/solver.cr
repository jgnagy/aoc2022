#!/usr/bin/env ruby

FILENAME = "input.txt"

class Grid
  property points
  property resting_grains

  def initialize(has_floor = false)
    @points = {} of Array(Int32) => Point
    @resting_grains = [] of Grain
    @has_floor = has_floor
    @lowest_rock_y = 0
  end

  def import_from(file)
    File.each_line(file) do |line|
      imported_points = Rock.from_line(line, self)
      imported_points.each { |point| @points[point.coordinates] = point }
    end
  end

  def lowest_rock_y
    if @lowest_rock_y.zero?
      @lowest_rock_y = points.values.select { |p| p.is_a?(Rock) }.map { |r| r.y }.min
    else
      @lowest_rock_y
    end
  end

  def has_floor?
    @has_floor.dup
  end

  def floor_level
    lowest_rock_y - 2
  end

  def to_s
    lines = [] of String
    x_vals = points.keys.map { |k| k.first }.sort
    (floor_level..0).to_a.reverse.each do |y|
      line = [] of String
      (x_vals.first..x_vals.last).each do |x|
        if y == floor_level
          line << "#"
        else
          point = points[[x, y]]?
          if point
            line << point.class.string_form
          else
            line << "."
          end
        end
      end
      lines << line.join
    end
    lines.join("\n")
  end
end

class Point
  @@string_form = "."

  getter x
  getter y
  getter grid

  def self.string_form
    @@string_form
  end

  def initialize(x : Int32, y : Int32, grid : Grid)
    @x = x
    @y = y.negative? ? y : y * -1
    @grid = grid
  end

  def coordinates
    [x, y]
  end
end

class Grain < Point
  @@string_form = "o"

  def self.generate(grid)
    new(500, 0, grid)
  end

  def drop!(direction = :down)
    # can't drop any further if we're sitting right above the floor
    if grid.has_floor? && y == grid.floor_level + 1
      return put_to_rest!
    end

    case direction
    when :down
      handle_down!
    when :left
      handle_left!
    when :right
      handle_right!
    end
  end

  private def handle_down!
    if grid.points.has_key?([500, 0])
      nil # finishes part 2
    elsif grid.points.has_key?([x, y - 1])
      drop!(direction: :left)
    elsif y < grid.lowest_rock_y && !grid.has_floor?
      nil # finishes part 1
    else
      @y = y - 1
      drop!
    end
  end

  private def handle_left!
    if grid.points.has_key?([x - 1, y - 1])
      drop!(direction: :right)
    else
      @y = y - 1
      @x = x - 1
      drop!
    end
  end

  private def handle_right!
    if grid.points.has_key?([x + 1, y - 1]) ||
        (grid.has_floor? && grid.floor_level == y - 1)
      put_to_rest!
    elsif grid.points.has_key?([x + 1, y - 1]) &&
          grid.has_floor? &&
          coordinates == [500, 0]
      put_to_rest!
    else
      @y = y - 1
      @x = x + 1
      drop!
    end
  end

  private def put_to_rest!
    grid.points[coordinates] = self
    grid.resting_grains << self
    self
  end
end

class Rock < Point
  @@string_form = "#"

  def self.from_line(line, grid)
    points = [] of Rock
    pairs = line.chomp.split(" -> ").map { |p| p.split(",").map { |i| i.to_i } }
    pairs.each_with_index do |pair, idx|
      break unless pairs[idx + 1]?

      start = new(pair.first, pair.last, grid)
      dest = new(pairs[idx + 1].first, pairs[idx + 1].last, grid)
      points += start.all_points_to(dest)
    end

    points
  end

  def all_points_to(other)
    if x == other.x
      first, second = [y, other.y].sort
      (first..second).map { |val| Rock.new(x, val, grid) }
    else
      first, second = [x, other.x].sort
      (first..second).map { |val| Rock.new(val, y, grid) }
    end
  end
end

grid = Grid.new
grid.import_from(FILENAME)

grain_of_sand = Grain.generate(grid)
until grain_of_sand.nil?
  grain_of_sand = grain_of_sand.drop!
  grain_of_sand = Grain.generate(grid) if grain_of_sand
end

puts "Part 1: #{grid.resting_grains.size}"

grid = Grid.new(has_floor: true)
grid.import_from(FILENAME)

grain_of_sand = Grain.generate(grid)
until grain_of_sand.nil?
  grain_of_sand = grain_of_sand.drop!
  grain_of_sand = Grain.generate(grid) if grain_of_sand
end

puts "Part 2: #{grid.resting_grains.size}"
