loop do
  collision = entity.current_collision
  if collision.kind == Crystal2Day::CollisionReference::Kind::ENTITY
    if collision.other_object.type_name == "Figure"
      if collision.other_object.position.y.to_i == 0
        temp = (collision.other_object.position.x - 25.0) / 100.0
        # The following frequencies are for the notes [a, g, f, e, d], so this is essentially some weird pitch-shifted d minor
        pitches = [440.0, 391.995, 349.228, 329.628, 293.665]
        entity.set_state("sound_pitch", pitches[temp.floor.to_i] / 440.0)
        entity.call_proc("PlaySound")
      end
    end
    collision.other_object.velocity.y = -100
  end
  Fiber.yield
end
