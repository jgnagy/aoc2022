#!/usr/bin/env ruby

require "pry"

FILENAME = "input.txt"
LINE_PARSER = /Sensor at x=(?<sx>[0-9-]+), y=(?<sy>[0-9-]+): closest beacon is at x=(?<bx>[0-9-]+), y=(?<by>[0-9-]+)/
              .freeze

class Grid
  attr_accessor :beacons, :sensors

  def initialize
    @beacons = []
    @sensors = {}
  end

  def import_points(line)
    data = LINE_PARSER.match(line.chomp)

    sensor = Sensor.new([data["sx"].to_i, data["sy"].to_i], self)
    beacon = [data["bx"].to_i, data["by"].to_i]
    sensor.nearest_beacon = beacon
    add_beacon(beacon)
    add_sensor(sensor)
  end

  def add_beacon(beacon)
    beacons << beacon unless beacons.include?(beacon)
  end

  def add_sensor(sensor)
    sensors[sensor.coordinates] = sensor
  end

  def sensor_coordinates
    @sensor_coordinates ||= sensors.keys
  end

  def spots_with_no_beacons_for_row(y_value)
    all_values = []
    sensors.each_value { |s| all_values += s.no_beacons_for_row(y_value) }
    ((all_values - sensor_coordinates) - beacons).uniq
  end

  def shadowed_ranges_by_y_coordinate
    sensors.values.map { |s| SensorShadow.new(s) }.reduce(&:merge)
  end

  private

  def min_x
    (sensors.map(&:x) + beacons.map(&:first)).min - 3
  end

  def max_x
    (sensors.map(&:x) + beacons.map(&:first)).max + 3
  end

  def min_y
    (sensors.map(&:y) + beacons.map(&:last)).min - 3
  end

  def max_y
    (sensors.map(&:y) + beacons.map(&:last)).max + 3
  end
end

class SensorShadow
  attr_accessor :sensor

  def initialize(sensor)= @sensor = sensor

  def ranges(min = 0, max = 4000000)
    @ranges ||= calculate_ranges(min, max)
  end

  def sensors
    [sensor]
  end

  def merge(other)
    MergedSensorShadow.new([sensor], ranges)
                      .merge(MergedSensorShadow.new([other.sensor], other.ranges))
  end

  private

  def calculate_ranges(min, max)
    max_x = sensor.x + sensor.beacon_distance
    min_x = sensor.x - sensor.beacon_distance
    max_y = sensor.y + sensor.beacon_distance
    min_y = sensor.y - sensor.beacon_distance

    calculated_ranges = ([min_y, min].max..[max_y, max].min).to_h do |y_value|
      [
        y_value,
        [
          ([min, (sensor.x - taxi_adjust_x_for(y_value))].max..[max, (sensor.x + taxi_adjust_x_for(y_value).abs)].min)
        ]
      ]
    end
    calculated_ranges.default = []
    calculated_ranges
  end

  def min_for(val, constraint)
    constraint ? [val, constraint].min : val
  end

  def max_for(val, constraint)
    constraint ? [val, constraint].max : val
  end

  def taxi_adjust_x_for(y_value)
    sensor.beacon_distance - (y_value - sensor.y).abs
  end
end

class MergedSensorShadow
  attr_accessor :sensors, :ranges

  def initialize(sensors, ranges)
    @ranges = ranges
    @sensors = [*sensors]
  end

  def range_values_overlap?(a, b)
    a.include?(b.begin) || b.include?(a.begin)
  end

  def merge_range_values(a, b)
    [a.begin, b.begin].min..[a.end, b.end].max
  end

  def merge_overlapping_range_values(overlapping_ranges)
    overlapping_ranges.sort_by(&:begin).inject([]) do |acc, r|
      if !acc.empty? && range_values_overlap?(acc.last, r)
        acc[0...-1] + [merge_range_values(acc.last, r)]
      else
        acc + [r]
      end
    end
  end

  def merge(other)
    other = other.is_a?(self.class) ? other : self.class.new([other.sensor], other.ranges)
    new_ranges = Hash.new([])
    (ranges.keys + other.ranges.keys).uniq.each do |key|
      key_ranges = []
      if ranges[key].empty?
        new_ranges[key] = other.ranges[key]
        next
      elsif other.ranges[key].empty?
        new_ranges[key] = ranges[key]
        next
      end

      ranges[key].each do |range|
        other.ranges[key].each do |other_range|
          if range.cover?(other_range)
            key_ranges << range
          elsif other_range.cover?(range)
            key_ranges << other_range
          elsif range.include?(other_range.first) || other_range.include?(range.last)
            key_ranges << (range.first..other_range.last)
          elsif range.include?(other_range.last) || other_range.include?(range.first)
            key_ranges << (other_range.first..range.last)
          else
            key_ranges << range
            key_ranges << other_range
          end
        end
      end
      new_ranges[key] = merge_overlapping_range_values(key_ranges)
    end

    self.class.new(sensors + other.sensors, new_ranges)
  end
end

class Sensor
  attr_accessor :coordinates, :grid, :nearest_beacon

  def initialize(coordinates, grid)
    @coordinates = coordinates
    @grid = grid
  end

  def beacon_distance
    @beacon_distance ||= rectangular_distance_to(nearest_beacon)
  end

  def no_beacons_for_row(y_value)
    difference = if y_value > y
                   (y + beacon_distance) - y_value
                 elsif y_value < y
                   y_value - (y - beacon_distance)
                 else
                   beacon_distance
                 end
    return [] if difference.negative?
    return [[x, y_value]] if difference.zero?

    ((x - difference)..(x + difference)).map { [_1, y_value] }
  end

  def x() = coordinates.first
  def y() = coordinates.last

  def rectangular_distance_to(other_coordinates)
    (x - other_coordinates.first).abs + (y - other_coordinates.last).abs
  end

  private

  def calculate_no_beacon_range
    points = []
    ((x - beacon_distance)..(x + beacon_distance)).each do |x|
      first_y, second_y = [(y - beacon_distance), (y + beacon_distance)].sort
      (first_y..second_y).each do |y|
        potential_point = [x, y]
        next if grid.sensor_coordinates.include?(potential_point)
        next if [coordinates, nearest_beacon].include?(potential_point)
        next unless rectangular_distance_to(potential_point) <= beacon_distance

        points << potential_point
      end
    end
    points
  end
end

@grid = Grid.new

File.foreach(FILENAME) do |line|
  @grid.import_points(line)
end

puts "Part 1: #{@grid.spots_with_no_beacons_for_row(2000000).size}"

@solution = @grid.shadowed_ranges_by_y_coordinate.ranges.select { |k,v| v.size > 1 }
y_val = @solution.keys.first
x_val = @solution.values.first.first.last + (@solution.values.first.last.first - @solution.values.first.first.last)
puts "Part 2: #{(4_000_000 * x_val) + y_val}"
