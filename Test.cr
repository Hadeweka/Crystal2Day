# A simple example program to showcase some of the features of Crystal2Day.

require "./src/Crystal2Day.cr"

alias CD = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < CD::Scene
  # Map components
  @map = CD::Map.new
  @tileset = CD::Tileset.new

  # Background
  @bg = CD::Sprite.new

  # Gameplay
  @player = CD::EntityGroup.new
  @camera = CD::Camera.new

  def init
    texture_tileset = CD.rm.load_texture("ExampleTileset.png")
    @tileset.link_texture(texture_tileset)
    @tileset.fill_with_default_tiles(number: 8) # NOTE: This will become relevant for tile animations and information
    @tileset.tile_width = 50
    @tileset.tile_height = 50
    @map.tileset = @tileset
    @map.content.load_from_array!(generate_test_map(width: 200, height: 200))
    @map.background_tile = 0
    @map.z = 2
    @map.pin

    texture_bg = CD.rm.load_texture("ExampleSky.png")
    @bg.link_texture(texture_bg)
    @bg.position = CD.xy(-100, -100)
    @bg.parallax = CD.xy(0.1, 0.1)
    @bg.render_rect = CD::Rect.new(width: 2000, height: 2000)
    @bg.z = 1
    @bg.pin

    entity_type = CD::EntityType.from_json_file("ExampleEntityStatePlayer.json")
    @player.add_entity(entity_type, position: CD.xy(25, 0))

    @camera.follow_entity(@player.get_entity(0), shift: CD.xy(-WIDTH/2 + 25, -HEIGHT/2 + 25))
    @camera.z = 0
    @camera.pin

    CD.game_data.set_state("gravity", CD.xy(0, 100.0))
    CD.physics_time_step = 0.1
  end

  def update
    CD.current_window.title = "FPS: #{CD.get_fps.round.to_i}"

    @player.update
  end

  def draw
    @player.draw
  end

  def handle_event(event)
    if event.type == CD::Event::WINDOW
      if event.as_window_event.event == CD::WindowEvent::CLOSE
        CD.next_scene = nil
      end
    end

    @player.handle_event(event)
  end

  def exit
    CD.current_window.close
    CD.current_window = nil
  end

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
end

CD.run do
  CD::Window.new(title: "Hello", w: WIDTH, h: HEIGHT)
  CD.scene = CustomScene.new
  CD.main_routine
end
