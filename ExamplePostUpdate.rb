loop do
  if entity.position.y >= 0 && entity.position.x > -25
    entity.position.y = 0
    entity.velocity.y = 0
  end

  Fiber.yield
end
