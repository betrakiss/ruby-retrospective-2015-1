def move(snake, direction)
  grow(snake, direction).drop(1)
end

def grow(snake, direction)
  snake + [new_position(snake.last, direction)]
end

def new_food(food, snake, dimension)
  all_xs = (0...dimensions[:width]).to_a
  all_ys = (0...dimensions[:height]).to_a

  valid = all_xs.product(all_ys) - (snake + food)
  valid.sample
end

def obstacle_ahead?(snake, direction, dimensions)
  position_ahead = new_position(snake.last, direction)

  snake_ahead?(snake, position_ahead) or
    out_of_bounds?(position_ahead, dimensions)
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def out_of_bounds?(position, dimensions)
  not in_bounds?(position, dimensions)
end

def in_bounds?(position, dimensions)
  position.first.between?(0, dimensions[:width] - 1) and
    position.last.between?(0, dimensions[:height] - 1)
end

def new_position(old_position, direction)
  snake_x, snake_y = old_position
  direction_x, direction_y = direction

  [snake_x + direction_x, snake_y + direction_y]
end

def snake_ahead?(snake, position_ahead)
  snake.include?(position_ahead)
end
