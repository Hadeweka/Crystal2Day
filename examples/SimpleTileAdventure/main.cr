require "../../src/Crystal2Day.cr"

alias CD = Crystal2Day

WIDTH = 1600
HEIGHT = 900

CD.db.add_entity_proc("FigureMove") do |entity|
  speed = entity.get_state("speed").to_i32  # TODO: Currently, only 1, 2, 5, 10, 25 and 50 are working speeds - Fix this!
  case entity.get_state("moving_direction").to_i32
  when 2 then
    entity.position.y += speed
    entity.set_state("moving_direction", 0) if entity.position.y % 50 == 0
  when 4 then
    entity.position.x -= speed
    entity.set_state("moving_direction", 0) if entity.position.x % 50 == 0
  when 6 then
    entity.position.x += speed
    entity.set_state("moving_direction", 0) if entity.position.x % 50 == 0
  when 8 then
    entity.position.y -= speed
    entity.set_state("moving_direction", 0) if entity.position.y % 50 == 0
  else
    # Don't do anything
  end

end

class CustomScene < CD::Scene
  def init
    Crystal2Day.custom_loading_path = "examples/SimpleTileAdventure"

    map = add_map("Map1", tileset: CD::Tileset.from_json_file("ExampleTileset.json"))
    map.set_as_stream!
    map.content.load_from_text_file!("ExampleWorld.txt")
    map.content.background_tile = 0
    map.z = 2
    map.pin

    ui_camera = CD::Camera.new
    ui_camera.z = 4
    ui_camera.pin

    default_font = CD.rm.load_font(CD::Font.default_font_path, size: 50)

    some_text = CD::Text.new("FPS: 0", default_font)
    some_text.z = 4
    some_text.color = CD::Color.black
    some_text.position = CD.xy(0, 0)

    add_ui("FPS").add_text("Tracker", some_text)
    
    CD.db.load_entity_type_from_file("ExampleEntityStatePlayer.json")
    add_entity_group("PlayerGroup", auto_update: true, auto_physics: true, auto_events: true, auto_draw: true, capacity: 1)
    add_entity(group: "PlayerGroup", type: "Player", position: CD.xy(600, -50))

    camera = CD::Camera.new
    camera.follow_entity(entity_groups["PlayerGroup"].get_entity(0), shift: CD.xy(-WIDTH/2 + 25, -HEIGHT/2 + 25))
    camera.z = 0
    camera.pin
  end

  def update
    @uis["FPS"].update_text("Tracker", "FPS: #{CD.get_fps.round.to_i}")
  end

  def draw
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
  end
end

CD.run do
  CD::Window.new(title: "Simple Tile Adventure", w: WIDTH, h: HEIGHT)
  CD.scene = CustomScene.new
  CD.main_routine
end
