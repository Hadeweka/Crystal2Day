require "./src/Crystal2Day.cr"

alias C2D = Crystal2Day

class CustomScene < C2D::Scene
  @window : C2D::Window = C2D::Window.new(title: "Hello", w: 800, h: 600)

  def initialize
    super()
  end

  def handle_event(event)
    if event.type == C2D::Event::WINDOW
      if event.as_window_event.event == C2D::WindowEvent::CLOSE
        C2D.next_scene = nil
      end
    end
  end
end

C2D.init(debug: true)
C2D.scene = CustomScene.new
C2D.main_routine
C2D.quit
