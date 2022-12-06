# "move" => ["beats", "these"]
RULES = {
  "rock" => ["scissors"],
  "paper" => ["rock"],
  "scissors" => ["paper"]
}

# "this" => ["if", "these"]
TRANSLATIONS = {
  "rock" => ["A", "X"],
  "paper" => ["B", "Y"],
  "scissors" => ["C", "Z"]
}

def score_my_move(my_move)
  case my_move
  when "rock"
    1
  when "paper"
    2
  when "scissors"
    3
  end
end

def score_match(their_move, my_move)
  if RULES[my_move].includes?(their_move)
    6
  elsif their_move == my_move
    3
  else
    0
  end
end

def parse_guide_p1(file = "test_input.txt")
  game_points = [] of Int32
  File.each_line(file) do |line|
    their_move, my_move = line.split(" ").map do |move|
      TRANSLATIONS.select { |k, v| v.includes?(move) }.keys.first
    end

    game_points << (score_my_move(my_move) || 0) + (score_match(their_move, my_move) || 0)
  end
  game_points
end

def parse_guide_p2(file = "test_input.txt")
  game_points = [] of Int32

  File.each_line(file) do |line|
    their_move_label, my_goal = line.split(" ")
    their_move = TRANSLATIONS.select { |k, v| v.includes?(their_move_label) }.keys.first
    my_move = case my_goal
    when "X"
      RULES[their_move].sample
    when "Y"
      their_move
    when "Z"
      RULES.select { |k, v| k != their_move && v.includes?(their_move) }.keys.first
    end

    game_points << (score_my_move(my_move) || 0) + (score_match(their_move, my_move) || 0)
  end
  game_points
end

puts "Part 1: #{parse_guide_p1("input.txt").sum}"
puts "Part 2: #{parse_guide_p2("input.txt").sum}"
