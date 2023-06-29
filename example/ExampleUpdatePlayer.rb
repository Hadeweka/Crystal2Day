puts "Player Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}"

each_frame do
  entity.velocity.x = 0
  entity.velocity.y = 0

  if Crystal2Day.im.key_down?("left")
    entity.velocity.x = -1
  end
  if Crystal2Day.im.key_down?("right")
    entity.velocity.x = 1
  end
  if Crystal2Day.im.key_down?("up")
    entity.velocity.y = -1
  end
  if Crystal2Day.im.key_down?("down")
    entity.velocity.y = 1
  end

  entity.change_hook_page_to("fast") if Crystal2Day.im.key_down?("fast_mode")
end
