each_frame do
  entity.velocity.x = 0
  entity.velocity.y = 0
  
  if Crystal2Day.im.key_down?("left")
    entity.velocity.x = -5
  end
  if Crystal2Day.im.key_down?("right")
    entity.velocity.x = 5
  end
  if Crystal2Day.im.key_down?("up")
    entity.velocity.y = -5
  end
  if Crystal2Day.im.key_down?("down")
    entity.velocity.y = 5
  end

  entity.change_hook_page_to("main") unless Crystal2Day.im.key_down?("fast_mode")
end
