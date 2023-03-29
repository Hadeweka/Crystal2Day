require "./src/Crystal2Day.cr"

alias C2D = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < C2D::Scene
  @texture = C2D::Texture.new
  @map = C2D::Map.new
  @map_layer_2 = C2D::Map.new
  @map_drawing_rect = C2D::Rect.new(x: 100, y: 100, width: WIDTH, height: HEIGHT)

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

    @map.content.load_from_array!(generate_test_map(width: 200, height: 200))
    @map_layer_2.content.load_from_array!(generate_test_map(width: 200, height: 200, with_rocks: true))

    @map.link_texture(@texture)
    @map_layer_2.link_texture(@texture)

    @map.background_tile = 4

    @map_layer_2.z = 1
    
    box = C2D::ShapeBox.new(C2D.xy(100, 100), position: C2D.xy(WIDTH / 2 - 50, HEIGHT / 2 - 50))
    box.color = C2D::Color.black
    box.filled = true
    box.z = 10
    box.pin
  end

  def update
    @map_drawing_rect.y -= 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_W)
    @map_drawing_rect.y += 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_S)
    @map_drawing_rect.x -= 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_A)
    @map_drawing_rect.x += 10 if C2D::Keyboard.key_down?(C2D::Keyboard::K_D)

    @map.reload(@map_drawing_rect)
    @map_layer_2.reload(@map_drawing_rect)
  end

  def draw
    @map.draw
    @map_layer_2.draw
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
  end
end

C2D.run do
  C2D::Window.new(title: "Hello", w: WIDTH, h: HEIGHT)
  C2D.scene = CustomScene.new
  C2D.main_routine
end
