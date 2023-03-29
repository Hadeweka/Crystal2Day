require "./src/Crystal2Day.cr"

alias C2D = Crystal2Day

class CustomScene < C2D::Scene
  @texture = C2D::Texture.new
  @map = C2D::Map.new
  @player_cam = C2D::Rect.new(x: 100, y: 100, width: 800, height: 600)

  def init
    @texture.load_from_file!("ExampleTileset.png")

    @map.content = C2D::MapContent.new
    @map.content.not_nil!.generate_test_map(width: 10, height: 10)

    @map.link_texture(@texture)
    @map.background_tile = 4
    
    box = C2D::ShapeBox.new(C2D.xy(200, 200), position: C2D.xy(550, 350))
    box.color = C2D::Color.green
    box.filled = true
    box.z = 10
    box.pin
  end

  def update
    @player_cam.x += 1
    @player_cam.y += 2
    @map.reload(@player_cam)
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
  C2D::Window.new(title: "Hello", w: 800, h: 600)
  C2D.scene = CustomScene.new
  C2D.main_routine
end
