gravity = Crystal2Day.game_data.get_state("gravity")

loop do
  entity.velocity.y = -1000 if Crystal2Day.im.key_down?("up") && entity.position.y == 0 && entity.position.x >= -25
  entity.position.x -= 25 if Crystal2Day.im.key_down?("left")
  entity.position.x += 25 if Crystal2Day.im.key_down?("right") && (entity.position.y <= 0 || entity.position.x < -25)
  entity.accelerate(gravity)

  entity.change_hook_page_to("main") unless Crystal2Day.im.key_down?("fast_mode")
  Fiber.yield
end
