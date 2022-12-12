#!/usr/bin/env ruby

FILENAME = "input.txt"

class Monkey
  attr_accessor :items, :operation, :criteria, :true_partner, :false_partner, :inspected_items, :troop
  attr_reader :id

  def initialize(id)
    @id = id
    @inspected_items = 0
  end

  def inspect_items(less_worry: true)
    @inspected_items += items.size
    items.each do |item|
      item.worry_level = less_worry ? (operation.call(item.worry_level) / 3) : operation.call(item.worry_level)
      if item.worry_level % criteria == 0
        toss(item, troop.monkeys.find { _1.id == true_partner }, less_worry:)
      else
        toss(item, troop.monkeys.find { _1.id == false_partner }, less_worry:)
      end
    end
    @items = []
  end

  def toss(item, partner, less_worry: true)
    item.monkey = partner
    item.worry_level %= troop.all_criteria.reduce(:*) unless less_worry
    partner.items << item
  end
end

class MonkeyTroop
  attr_accessor :monkeys

  def initialize
    @monkeys = []
  end

  def all_criteria
    monkeys.map(&:criteria)
  end
end

class Item
  attr_accessor :worry_level, :monkey

  def initialize(worry_level, monkey)
    @worry_level = worry_level
    @monkey = monkey
  end
end

def build_troop(descriptions)
  troop = MonkeyTroop.new
  descriptions.each_with_index do |desc, idx|
    monkey = Monkey.new(idx)
    monkey.troop = troop
    desc.split("\n").each do |line|
      case line
      when /Starting items: ([0-9,\s]+)/
        monkey.items = Regexp.last_match(1).split(", ").map { Item.new(_1.to_i, monkey) }
      when /Operation: new = old ([*+] ([0-9]+|old))/
        op_items = Regexp.last_match(1).split(" ")
        operation = lambda do |level|
          level.send(
            op_items.first.to_sym,
            op_items.last == "old" ? level : op_items.last.to_i
          )
        end
        monkey.operation = operation
      when /Test: divisible by ([0-9]+)/
        monkey.criteria = Regexp.last_match(1).to_i
      when /If true: throw to monkey ([0-9]+)/
        monkey.true_partner = Regexp.last_match(1).to_i
      when /If false: throw to monkey ([0-9]+)/
        monkey.false_partner = Regexp.last_match(1).to_i
      else
        next
      end
    end

    troop.monkeys << monkey
  end
  troop
end

@monkey_descriptions = File.read(FILENAME).split("\n\n")

part1_troop = build_troop(@monkey_descriptions)
20.times { part1_troop.monkeys.each(&:inspect_items) }
puts "Part 1: #{part1_troop.monkeys.map(&:inspected_items).sort.max(2).reduce(&:*)}"

# For part 2, comment out the above two lines and uncomment these
part2_troop = build_troop(@monkey_descriptions)
10000.times { part2_troop.monkeys.each { _1.inspect_items(less_worry: false) } }
puts "Part 2: #{part2_troop.monkeys.map(&:inspected_items).sort.max(2).reduce(&:*)}"
