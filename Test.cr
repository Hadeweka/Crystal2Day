require "./src/Crystal2Day.cr"

alias C2D = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < C2D::Scene
  @texture = C2D::Texture.new
  @map = C2D::Map.new
  @map_drawing_rect = C2D::Rect.new(x: 100, y: 100, width: WIDTH, height: HEIGHT)

  def init
    @texture.load_from_file!("ExampleTileset.png")

    @map.content = C2D::MapContent.new
    @map.content.not_nil!.generate_test_map(width: 1000, height: 1000)

    @map.link_texture(@texture)
    @map.background_tile = 4
    
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
  end

  def draw
    @map.draw
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
