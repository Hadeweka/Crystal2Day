loop do
  collision = entity.current_collision
  if collision.kind == Crystal2Day::CollisionReference::Kind::ENTITY
    collision.other_object.velocity.y = -100
    temp = (collision.other_object.position.x - 25.0) / 100.0
    pitches = [440.0, 391.995, 349.228, 329.628, 293.665]
    entity.set_state("sound_pitch", pitches[temp.floor.to_i] / 440.0)
    entity.call_proc("PlaySound")
  end
  Fiber.yield
end
