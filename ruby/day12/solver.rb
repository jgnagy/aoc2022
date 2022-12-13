#!/usr/bin/env ruby
# frozen_string_literal: true

require "connected"
FILENAME = "input.txt"

class Terrain
  attr_accessor :peaks

  def attempted_paths_cache() = @attempted_paths_cache ||= {}
  def initialize() = @peaks = []
end

class Peak
  include Connected::Vertex

  LETTERS = ("a".."z").to_a

  attr_reader :x, :y, :elevation_letter, :terrain

  def initialize(x, y, elevation_letter, terrain)
    @x = x
    @y = y
    @elevation_letter = elevation_letter
    @terrain = terrain
  end

  def name() = "{#{x}, #{y}}"
  def start?() = @elevation_letter == "S"
  def destination?() = @elevation_letter == "E"

  def elevation
    @elevation ||= case @elevation_letter
                   when "S"
                     0
                   when "E"
                     25
                   else
                     LETTERS.find_index(@elevation_letter)
                   end
  end

  def nearby_reachable_peaks
    @nearby_reachable_peaks ||= terrain.peaks.select do |p|
      (x == p.x && [y - 1, y + 1].include?(p.y)) || (y == p.y && [x - 1, x + 1].include?(p.x))
    end
  end

  def connections
    @connections ||= nearby_reachable_peaks.map { Climb.new(self, _1) }
  end
end

class Climb
  include Connected::Edge

  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to
  end

  def state
    (-2..1).include?(to.elevation - from.elevation) ? :open : :closed
  end
end

class Path < Connected::Path
end

@raw_file = File.read(FILENAME).split("\n")
@terrain = Terrain.new
@x = 0
@y = @raw_file.size - 1

@raw_file.each do |line|
  @x = 0
  line.strip.chars.each do |l|
    peak = Peak.new(@x, @y, l, @terrain)
    @terrain.peaks << peak
    @x += 1
  end
  @y -= 1
end

@start = @terrain.peaks.find(&:start?)
@destination = @terrain.peaks.find(&:destination?)
@solution = Path.all(
  from: @start, to: @destination, cache: @terrain.attempted_paths_cache, min_by: :hops
).first
puts "Part 1: #{@solution.hops}"

@new_start_options = @terrain.peaks.select do |p|
  p.elevation.zero? && p.nearby_reachable_peaks.any? { |o| o.elevation == 1 }
end
@solutions = @new_start_options.map do |s|
  Path.all(from: s, to: @destination, cache: @terrain.attempted_paths_cache, min_by: :hops).first
end
puts "Part 2: #{@solutions.compact.map(&:hops).min}"
