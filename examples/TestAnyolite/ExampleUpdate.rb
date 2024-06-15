puts "Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}"

each_frame do
  entity.accelerate(Crystal2Day.xy(0, 1))
end
