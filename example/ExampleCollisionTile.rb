each_frame do
  collision = entity.current_collision
  if collision.tile.get_flag("solid") && collision.other_position.y >= entity.position.y - 5
    entity.velocity.y = 0.0
    entity.position.y -= 1
    entity.set_state("on_ground", true)
  end

  if collision.tile.get_flag("solid") && collision.other_position.y < entity.position.y - 55
    entity.velocity.y = 0.0
  end

  if collision.tile.get_flag("solid") && collision.other_position.x > entity.position.x
    entity.position.x -= 1
  elsif collision.tile.get_flag("solid") && collision.other_position.x < entity.position.x - 50
    entity.position.x += 1
  end
end
