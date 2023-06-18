# A simple example program to showcase some of the features of Crystal2Day.

require "./src/Crystal2Day.cr"

alias CD = Crystal2Day

CD.db.add_entity_proc("FigureHandleEvent") do |entity|
  event = Crystal2Day.last_event
  if valid_event = event
    if valid_event.type == Crystal2Day::Event::WINDOW
      puts "You triggered a Window Event!"
    end
  end
end

CD.db.add_entity_proc("FigurePostUpdate") do |entity|
  if entity.position.y >= 0 && entity.position.x > -25
    entity.position.y = 0
    entity.velocity.y = 0
  end
end

CD.db.add_entity_proc("PlaySound") do |entity|
  # TODO: Since the scene is not yet fully exposed to the entities, we need to rely on this hack for now
  sound = CD.scene.not_nil!.as(CustomScene).example_sound
  sound.pitch = entity.get_state("sound_pitch").to_f32
  sound.play
end

WIDTH = 1600
HEIGHT = 900

class CustomScene < CD::Scene
  getter example_sound = CD::Sound.new

  def init
    texture_tileset = CD.rm.load_texture("ExampleTileset.png")
    tileset = CD::Tileset.new
    tileset.link_texture(texture_tileset)
    tileset.fill_with_default_tiles(number: 8) # NOTE: This will become relevant for tile animations and information
    tileset.tile_width = 50
    tileset.tile_height = 50

    map = add_map("Map1", tileset: tileset)
    map.content.load_from_array!(generate_test_map(width: 200, height: 200))
    map.background_tile = 0
    map.z = 2
    map.pin

    texture_bg = CD.rm.load_texture("ExampleSky.png")
    bg = CD::Sprite.new
    bg.link_texture(texture_bg)
    bg.position = CD.xy(-100, -100)
    bg.parallax = CD.xy(0.1, 0.1)
    bg.render_rect = CD::Rect.new(width: 2000, height: 2000)
    bg.z = 1
    bg.pin

    CD.db.load_entity_type_from_file("ExampleEntityStateFigure.json")
    CD.db.load_entity_type_from_file("ExampleEntityStatePlayer.json")

    add_entity_group("PlayerGroup", auto_update: true, auto_physics: true, auto_events: true, auto_draw: true, capacity: 1)
    add_entity_group("FigureGroup", auto_update: true, auto_physics: true, auto_events: true, auto_draw: true, capacity: 5)

    add_entity(group: "PlayerGroup", type: "Player", position: CD.xy(500, 0))
    5.times {|i| add_entity(group: "FigureGroup", type: "Figure", position: CD.xy(25 + 100*i, 0))}

    camera = CD::Camera.new
    camera.follow_entity(entity_groups["PlayerGroup"].get_entity(0), shift: CD.xy(-WIDTH/2 + 25, -HEIGHT/2 + 25))
    camera.z = 0
    camera.pin

    CD.game_data.set_state("gravity", CD.xy(0, 100.0))
    CD.physics_time_step = 0.01
    CD.number_of_physics_steps = 10

    CD.im.set_key_table_entry("action_key", [CD::Keyboard::K_SPACE])
    CD.im.set_key_table_entry("up", [CD::Keyboard::K_UP, CD::Keyboard::K_W])
    CD.im.set_key_table_entry("left", [CD::Keyboard::K_LEFT, CD::Keyboard::K_A])
    CD.im.set_key_table_entry("right", [CD::Keyboard::K_RIGHT, CD::Keyboard::K_D])

    self.collision_matrix.link(entity_groups["FigureGroup"])
    self.collision_matrix.link(entity_groups["FigureGroup"], maps["Map1"])
    self.collision_matrix.link(entity_groups["PlayerGroup"], entity_groups["FigureGroup"])
    self.collision_matrix.link(entity_groups["PlayerGroup"], maps["Map1"])
    
    self.collision_matrix.determine_collisions

    @example_sound.load_from_file!("ExampleSound.ogg")
  end

  def update
    CD.current_window.title = "FPS: #{CD.get_fps.round.to_i}"
  end

  def draw
  end

  def handle_event(event)
    if event.type == CD::Event::WINDOW
      if event.as_window_event.event == CD::WindowEvent::CLOSE
        CD.next_scene = nil
      end
    end

    if CD.im.check_event_for_key_press(event, "action_key")
      puts "Action!"
    end
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
