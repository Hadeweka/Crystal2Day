each_frame do
  entity.each_entity_collision do |collision|
    if collision.entity.type_name == "Figure"
      if collision.entity.aligned_position.y.to_i % 50 == 25
        temp = (collision.entity.position.x - 25.0) / 100.0
        # The following frequencies are for the notes [a, g, f, e, d], so this is essentially some weird pitch-shifted d minor
        pitches = [440.0, 391.995, 349.228, 329.628, 293.665]
        entity.set_state("sound_pitch", pitches[temp.floor.to_i] / 440.0)
        entity.call_proc("PlaySound")
      end
    end
    collision.entity.velocity.y = -1
  end
end
