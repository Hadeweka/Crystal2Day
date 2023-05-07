entity.set_state("test", 12345)

100.times do
  entity.accelerate(Crystal2Day.xy(rand - 0.5, rand - 0.5) * 100.0)
  Fiber.yield
end

gravity = Crystal2Day.game_data.get_state("gravity")

puts "ID: #{entity.get_state("id")}, Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"

entity.call_proc("test_proc")

loop do
  entity.accelerate(gravity)
  Fiber.yield
end
