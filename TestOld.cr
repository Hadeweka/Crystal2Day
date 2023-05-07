# A simple example program to showcase some of the features of Crystal2Day.

require "./src/Crystal2Day.cr"

alias CD = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < CD::Scene
  @texture = CD::Texture.new
  @texture2 = CD::Texture.new
  @texture3 = CD::Texture.new
  @map = CD::Map.new
  @map_layer_2 = CD::Map.new
  @tileset = CD::Tileset.new
  @camera = CD::Camera.new(position: CD.xy(-WIDTH/2, -HEIGHT/2))
  @entities = CD::EntityGroup.new

  def generate_test_map(width : UInt32, height : UInt32, with_rocks : Bool = false)
    array = Array(Array(CD::TileID)).new(initial_capacity: height)

    0.upto(height - 1) do |y|
      array.push Array(CD::TileID).new(initial_capacity: width)
      0.upto(width - 1) do |x|
        if with_rocks
          array[y].push(rand < 0.1 ? 6u32 : 0u32)
        else
          array[y].push (rand(3).to_u32 + 1)
        end
      end
    end

    return array
  end

  def init
    @texture.load_from_file!("ExampleTileset.png")
    @texture2.load_from_file!("ExampleSprite.png")
    @texture3.load_from_file!("ExampleSky.png")

    sprite = CD::Sprite.new
    sprite.link_texture(@texture2)
    sprite.source_rect = CD::Rect.new(x: 0, y: 0, width: 50, height: 50)
    sprite.z = 20
    animation_template = CD::AnimationTemplate.new(start_frame: 1, loop_end_frame: 2, frame_delay: 20)
    sprite.animation = CD::Animation.new(animation_template)

    bg = CD::Sprite.new
    bg.link_texture(@texture3)
    bg.position = CD.xy(0, 0)
    bg.parallax = CD.xy(0.1, 1.0)
    bg.z = 25

    CD.game_data.set_state("gravity", CD.xy(0, 9.81))
    CD.physics_time_step = 0.1

    # NOTE: This is a Ruby coroutine!
    update_hook = CD::CoroutineTemplate.from_block do |entity|
      entity.set_state("test", 12345)
      100.times {entity.accelerate(Crystal2Day.xy(rand - 0.5, rand - 0.5)*100.0); Fiber.yield}
      gravity = Crystal2Day.game_data.get_state("gravity")
      puts "ID: #{entity.get_state("id")}, Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}, Gravity: #{gravity}"
      entity.call_proc("test_proc")
      loop {entity.accelerate(gravity); Fiber.yield}
    end

    entity_type = CD::EntityType.new(name: "TestEntity")
    entity_type.add_default_state("test", 12345)
    entity_type.add_coroutine_template("update", update_hook)
    entity_type.add_sprite sprite

    # NOTE: This is a Crystal callback!
    entity_type.add_default_proc("test_proc") do |entity|
      puts "Hello world from a #{CD.scene.class}!"
    end
    
    10.times {@entities.add_entity(entity_type)}
    0.upto(@entities.number - 1) do |i|
      @entities.get_entity(i).set_state("id", i.to_s)
    end

    # NOTE: Above we used Ruby coroutines and Crystal callbacks.
    # They seem quite similar, but they have drastical differences.
    # The Ruby coroutines can only access the entity state and the Crystal callbacks.
    # This way, you can limit scripting to certain elements.
    # But the coroutines also allow for suspension, while keeping their context.
    # This is not possible with the Crystal callbacks.
    # They however can do nearly anything and access most other functions.

    @map.content.load_from_array!(generate_test_map(width: 200, height: 200))
    @map_layer_2.content.load_from_array!(generate_test_map(width: 200, height: 200, with_rocks: true))

    @tileset.link_texture(@texture)
    @tileset.fill_with_default_tiles(number: 8) # NOTE: This will become relevant for tile animations and information
    @tileset.tile_width = 50
    @tileset.tile_height = 50

    @map.tileset = @tileset
    @map_layer_2.tileset = @tileset

    @map.background_tile = 4

    @map_layer_2.z = 1
    
    box = CD::ShapeBox.new(CD.xy(100, 100), position: CD.xy(-50, -50))
    box.color = CD::Color.black
    box.filled = true
    box.z = 10
    box.pin

    triangle = CD::ShapeTriangle.new(position: CD.xy(-50, 0), side_1: CD.xy(100, 0), side_2: CD.xy(50, 50))
    triangle.color = CD::Color.red
    triangle.filled = true
    triangle.z = 11
    triangle.pin

    circle = CD::ShapeCircle.new(position: CD.xy(0.0, 0.0), radius: 50.0)
    circle.color = CD::Color.green
    circle.z = 12
    circle.filled = false
    circle.pin

    ellipse = CD::ShapeEllipse.new(position: CD.xy(0.0, 0.0), semiaxes: CD.xy(100.0, 50.0))
    ellipse.color = CD::Color.yellow
    ellipse.z = 13
    ellipse.number_of_render_iterations = 8
    ellipse.filled = false
    ellipse.pin

    bg.pin

    @camera.pin
    @map.pin
    @map_layer_2.pin
  end

  def update
    @camera.position.y -= 10 if CD::Keyboard.key_down?(CD::Keyboard::K_W)
    @camera.position.y += 10 if CD::Keyboard.key_down?(CD::Keyboard::K_S)
    @camera.position.x -= 10 if CD::Keyboard.key_down?(CD::Keyboard::K_A)
    @camera.position.x += 10 if CD::Keyboard.key_down?(CD::Keyboard::K_D)
    CD.current_window.title = "FPS: #{CD.get_fps.round.to_i}"

    @entities.update
  end

  def draw
    @entities.draw
  end

  def handle_event(event)
    if event.type == CD::Event::WINDOW
      if event.as_window_event.event == CD::WindowEvent::CLOSE
        CD.next_scene = nil
      end
    end
  end

  def exit
    CD.current_window.close
    CD.current_window = nil
    @entities.clear
  end
end

CD.run do
  CD::Window.new(title: "Hello", w: WIDTH, h: HEIGHT)
  CD.scene = CustomScene.new
  CD.main_routine
end
