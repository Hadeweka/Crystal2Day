gravity = Crystal2Day.game_data.get_state("gravity")

puts "Player Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"
entity.set_state("on_ground", true)

each_frame do
  if Crystal2Day.im.key_down?("up") && entity.get_state("on_ground")
    entity.velocity.y = -200
    entity.set_state("on_ground", false)
  end
  if Crystal2Day.im.key_down?("left")
    entity.velocity.x = -25 
  elsif Crystal2Day.im.key_down?("right")
    entity.velocity.x = 25
  else
    entity.velocity.x = 0
  end
  entity.accelerate(gravity) unless entity.get_state("on_ground")

  entity.set_state("on_ground", false)

  entity.change_hook_page_to("fast") if Crystal2Day.im.key_down?("fast_mode")
end
