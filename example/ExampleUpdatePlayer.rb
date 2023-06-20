gravity = Crystal2Day.game_data.get_state("gravity")

puts "Player Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"

each_frame do
  entity.velocity.y = -200 if Crystal2Day.im.key_down?("up") && entity.position.y == 0 && entity.position.x >= -25
  entity.position.x -= 5 if Crystal2Day.im.key_down?("left")
  entity.position.x += 5 if Crystal2Day.im.key_down?("right") && (entity.position.y <= 0 || entity.position.x < -25)
  entity.accelerate(gravity)

  entity.change_hook_page_to("fast") if Crystal2Day.im.key_down?("fast_mode")
end
