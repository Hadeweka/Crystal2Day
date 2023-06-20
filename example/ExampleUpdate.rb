gravity = Crystal2Day.game_data.get_state("gravity")

puts "Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"

each_frame do
  entity.accelerate(gravity)
end
