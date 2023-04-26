# A simple example program to showcase some of the features of Crystal2Day.

require "./src/Crystal2Day.cr"

alias C2D = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < C2D::Scene
  @texture = C2D::Texture.new
  @map = C2D::Map.new
  @map_layer_2 = C2D::Map.new
  @tileset = C2D::Tileset.new
  @camera = C2D::Camera.new(position: C2D.xy(-WIDTH/2, -HEIGHT/2))
  @entities = C2D::EntityGroup.new

  def generate_test_map(width : UInt32, height : UInt32, with_rocks : Bool = false)
    array = Array(Array(C2D::TileID)).new(initial_capacity: height)

    0.upto(height - 1) do |y|
      array.push Array(C2D::TileID).new(initial_capacity: width)
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

    # NOTE: This is a Ruby coroutine!
    update_hook = C2D::CoroutineTemplate.from_block do |entity|
      entity.set_state("test", 12345)
      100.times {Fiber.yield}
      puts "ID: #{entity.get_state("id")}, Test: #{entity.get_state("test")}, Magic number: #{entity.magic_number}, Position: #{entity.position}"
      entity.call_proc("test_proc")
    end

    entity_type = C2D::EntityType.new(name: "TestEntity")
    entity_type.add_default_state("test", 12345)
    entity_type.add_coroutine_template("update", update_hook)

    # NOTE: This is a Crystal callback!
    entity_type.add_default_proc("test_proc") do |entity|
      puts "Hello world from a #{C2D.scene.class}!"
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
    
    box = C2D::ShapeBox.new(C2D.xy(100, 100), position: C2D.xy(-50, -50))
    box.color = C2D::Color.black
    box.filled = true
    box.z = 10
    box.pin

    triangle = C2D::ShapeTriangle.new(position: C2D.xy(-50, 0), side_1: C2D.xy(100, 0), side_2: C2D.xy(50, 50))
    triangle.color = C2D::Color.red
    triangle.filled = true
    triangle.z = 11
    triangle.pin

    circle = C2D::ShapeCircle.new(position: C2D.xy(0.0, 0.0), radius: 50.0)
    circle.color = C2D::Color.green
    circle.z = 12
    circle.filled = false
    circle.pin

    ellipse = C2D::ShapeEllipse.new(position: C2D.xy(0.0, 0.0), semiaxes: C2D.xy(100.0, 50.0))
    ellipse.color = C2D::Color.yellow
    ellipse.z = 13
    ellipse.number_of_render_iterations = 8
    ellipse.filled = false
    ellipse.pin

    @camera.pin
    @map.pin
    @map_layer_2.pin
  end

  def update
    @camera.position.y -= 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_W)
    @camera.position.y += 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_S)
    @camera.position.x -= 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_A)
    @camera.position.x += 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_D)
    C2D.current_window.title = "FPS: #{C2D.get_fps.round.to_i}"

    @entities.update
  end

  def draw
  end

  def handle_event(event)
    if event.type == C2D::Event::WINDOW
      if event.as_window_event.event == C2D::WindowEvent::CLOSE
        C2D.next_scene = nil
      end
    end
  end

  def exit
    C2D.current_window.close
    C2D.current_window = nil
    @entities.clear
  end
end

C2D.run do
  C2D::Window.new(title: "Hello", w: WIDTH, h: HEIGHT)
  C2D.scene = CustomScene.new
  C2D.main_routine
end
