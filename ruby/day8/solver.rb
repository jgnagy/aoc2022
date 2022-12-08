#!/usr/bin/env ruby

FILENAME = "input.txt"

class Tree
  attr_accessor :height, :x, :y, :forest

  def initialize(height, x, y)
    @height = height
    @x = x
    @y = y
  end

  def in_same_column() = forest.trees_with_x(x) - [self]
  def in_same_row() = forest.trees_with_y(y) - [self]

  def northern_neighbors
    return [] if y == forest.max_y

    @northern_neighbors ||= in_same_column.select { |t| t.y > y }.sort_by(&:y)
  end

  def southern_neighbors
    return [] if y.zero?

    @southern_neighbors ||= in_same_column.select { |t| t.y < y }.sort_by(&:y).reverse
  end

  def western_neighbors
    return [] if x.zero?

    @western_neighbors ||= in_same_row.select { |t| t.x < x }.sort_by(&:x).reverse
  end

  def eastern_neighbors
    return [] if x == forest.max_x

    @eastern_neighbors ||= in_same_row.select { |t| t.x > x }.sort_by(&:x)
  end

  def viewing_distance_for(neighbors)
    viewing_distance = 0
    neighbors.each do |t|
      viewing_distance += 1
      break unless t.height < height
    end
    viewing_distance
  end

  def viewing_distance_score
    @viewing_distance_score ||=
      [
        viewing_distance_for(northern_neighbors),
        viewing_distance_for(southern_neighbors),
        viewing_distance_for(western_neighbors),
        viewing_distance_for(eastern_neighbors)
      ].reduce(&:*)
  end
end

class Forest
  attr_accessor :trees

  def initialize() = @trees = []

  def max_x() = @max_x ||= trees.max_by(&:x).x
  def max_y() = @max_y ||= trees.max_by(&:y).y

  def trees_with_x(x)
    @trees_with_x ||= {}
    @trees_with_x[x] ||= trees.select { |t| t.x == x }
  end

  def trees_with_y(y)
    @trees_with_y ||= {}
    @trees_with_y[y] ||= trees.select { |t| t.y == y }
  end

  def edge_trees
    @edge_trees ||= trees.select { |t| t.x.zero? || t.y.zero? || t.y == max_y || t.x == max_y }
  end

  def trees_visible_from_edge
    edge_trees +
      (trees - edge_trees).select do |tree|
        tree.northern_neighbors.select { |t| t.height >= tree.height }.empty? ||
          tree.southern_neighbors.select { |t| t.height >= tree.height }.empty? ||
          tree.western_neighbors.select { |t| t.height >= tree.height }.empty? ||
          tree.eastern_neighbors.select { |t| t.height >= tree.height }.empty?
      end
  end

  def highest_viewing_distance() = trees.max_by(&:viewing_distance_score).viewing_distance_score
end

@raw_file = File.read(FILENAME).split("\n")
@forest = Forest.new
@x = 0
@y = @raw_file.size - 1

@raw_file.each do |line|
  @x = 0
  line.split("").each do |t|
    tree = Tree.new(t.to_i, @x, @y)
    tree.forest = @forest
    @forest.trees << tree
    @x += 1
  end
  @y -= 1
end

puts "Part 1: #{@forest.trees_visible_from_edge.size}"
puts "Part 2: #{@forest.highest_viewing_distance}"
