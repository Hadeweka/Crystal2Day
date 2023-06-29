each_frame do
  collision = entity.current_collision

  if collision.tile.get_flag("solid")
    if collision.other_position.x + 25 > entity.position.x
      puts "Blocked: Right" if entity.velocity.x > 0
      entity.velocity.x = 0 if entity.velocity.x > 0
    end

    if collision.other_position.x + 25 < entity.position.x
      puts "Blocked: Left" if entity.velocity.x < 0
      entity.velocity.x = 0 if entity.velocity.x < 0
    end

    if collision.other_position.y + 25 > entity.position.y
      puts "Blocked: Down" if entity.velocity.y > 0
      entity.velocity.y = 0 if entity.velocity.y > 0
    end
    
    if collision.other_position.y + 25 < entity.position.y
      puts "Blocked: Up" if entity.velocity.y < 0
      entity.velocity.y = 0 if entity.velocity.y < 0
    end
  end
end
