each_frame do
  collision = entity.current_collision

  # TODO: Add tile and entity size to this somehow

  if collision.tile.get_flag("solid")
    if collision.other_position.x + 25 > entity.aligned_position.x && (entity.aligned_position.y - collision.other_position.y - 25).abs < 50
      entity.velocity.x = 0 if entity.velocity.x > 0
    end

    if collision.other_position.x + 25 < entity.aligned_position.x && (entity.aligned_position.y - collision.other_position.y - 25).abs < 50
      entity.velocity.x = 0 if entity.velocity.x < 0
    end

    if collision.other_position.y + 25 > entity.aligned_position.y && (entity.aligned_position.x - collision.other_position.x - 25).abs < 50
      entity.velocity.y = 0 if entity.velocity.y > 0
    end
    
    if collision.other_position.y + 25 < entity.aligned_position.y && (entity.aligned_position.x - collision.other_position.x - 25).abs < 50
      entity.velocity.y = 0 if entity.velocity.y < 0
    end
  end
end
