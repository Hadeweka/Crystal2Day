gravity = Crystal2Day.game_data.get_state("gravity")

each_frame do
  if Crystal2Day.im.key_down?("up") && entity.get_state("on_ground")
    entity.velocity.y = -250
    entity.set_state("on_ground", false)
  end
  if Crystal2Day.im.key_down?("left")
    entity.velocity.x = -50 
  elsif Crystal2Day.im.key_down?("right")
    entity.velocity.x = 50
  else
    entity.velocity.x = 0
  end
  entity.accelerate(gravity) unless entity.get_state("on_ground")

  entity.set_state("on_ground", false)

  entity.change_hook_page_to("main") unless Crystal2Day.im.key_down?("fast_mode")
end
