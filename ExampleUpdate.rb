gravity = Crystal2Day.game_data.get_state("gravity")

puts "Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"

loop do
  entity.velocity.y = -200 if Crystal2Day::Keyboard.key_down?(Crystal2Day::Keyboard::K_W) && entity.position.y == 0
  entity.position.x -= 5 if Crystal2Day::Keyboard.key_down?(Crystal2Day::Keyboard::K_A)
  entity.position.x += 5 if Crystal2Day::Keyboard.key_down?(Crystal2Day::Keyboard::K_D) && (entity.position.y <= 0 || entity.position.x < -25)
  entity.accelerate(gravity)
  Fiber.yield
end
