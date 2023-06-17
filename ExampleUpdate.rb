gravity = Crystal2Day.game_data.get_state("gravity")

puts "Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"

loop do
  entity.velocity.y = -200 if Crystal2Day.im.key_down?("up") && entity.position.y == 0 && entity.position.x >= -25
  entity.position.x -= 5 if Crystal2Day.im.key_down?("left")
  entity.position.x += 5 if Crystal2Day.im.key_down?("right") && (entity.position.y <= 0 || entity.position.x < -25)
  entity.accelerate(gravity)
  Fiber.yield
end
