# A simple example program to showcase some of the features of Crystal2Day.

require "../../src/Crystal2Day.cr"

alias CD = Crystal2Day

WIDTH = 1600
HEIGHT = 900

class CustomScene < CD::Scene
  def init
    Crystal2Day.custom_loading_path = "examples/TestRaw"

    texture_bg = CD.rm.load_texture("ExampleSky.png")
    bg = CD::Sprite.new
    bg.link_texture(texture_bg)
    bg.position = CD.xy(-100, -100)
    bg.parallax = CD.xy(0.1, 0.1)
    bg.render_rect = CD::Rect.new(width: 2000, height: 2000)
    bg.z = 1
    bg.pin
  end

  def update
    CD.current_window.title = "FPS: #{CD.get_fps.round.to_i}"
  end

  def draw
  end

  def handle_event(event)
    if event.is_quit_event?
      CD.next_scene = nil
    end
  end

  def exit
    CD.current_window.close
    CD.current_window = nil
  end
end

CD.run do
  CD::Window.new(title: "Hello", w: WIDTH, h: HEIGHT)
  CD.scene = CustomScene.new
  CD.main_routine
end
