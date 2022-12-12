#!/usr/bin/env ruby
# frozen_string_literal: true

require "connected"
FILENAME = "input.txt"

class Terrain
  attr_accessor :peaks

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
      (-2..1).include?(p.elevation - elevation) &&
        ((x == p.x && [y - 1, y + 1].include?(p.y)) || (y == p.y && [x - 1, x + 1].include?(p.x)))
    end
  end

  def connections
    @connections ||= nearby_reachable_peaks.map { Climb.new(self, _1) }
  end
end

class Climb
  include Connected::Edge

  attr_reader :from, :to, :state

  def initialize(from, to)
    @from = from
    @to = to
    @state = :open
  end
end

ATTEMPTED_DESTINATIONS = Hash.new([])

class Path < Connected::Path
  def self.all(from:, to:)
    paths = []

    path_queue = from.neighbors.map { |n| new([from, n]) }

    until path_queue.empty?
      this_path = path_queue.pop
      next unless this_path.open?

      if ATTEMPTED_DESTINATIONS[this_path.to.name][0]&.<= this_path.hops
        next if ATTEMPTED_DESTINATIONS[this_path.to.name][0] < this_path.hops
        next if ATTEMPTED_DESTINATIONS[this_path.to.name][1] >= 3

        ATTEMPTED_DESTINATIONS[this_path.to.name][1] += 1
      else
        ATTEMPTED_DESTINATIONS[this_path.to.name] = [this_path.hops, 1]
      end

      if this_path.to == to
        paths << this_path
      else
        highhops = paths.max_by(&:hops)&.hops

        this_path.to.neighbors.each do |n|
          new_path = this_path.branch(n)
          next unless new_path
          next unless paths.empty? || new_path.hops <= highhops

          path_queue.unshift(new_path)
        end
      end
    end

    paths.sort_by(&:hops)
  end
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
@solution = Path.all(from: @start, to: @destination).first
puts "Part 1: #{@solution.hops}"

@new_start_options = @terrain.peaks.select do |p|
  p.elevation.zero? && p.nearby_reachable_peaks.any? { |o| o.elevation == 1 }
end
@solutions = @new_start_options.map { |s| Path.all(from: s, to: @destination).first }
puts "Part 2: #{@solutions.compact.map(&:hops).min}"
