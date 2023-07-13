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
end

CD.db.add_entity_proc("PlaySound") do |entity|
  channel = entity.get_state("sound_channel").to_i32
  unless CD.sb.sound_playing?(channel: channel)
    CD.sb.play_sound("example/ExampleSound.ogg", channel: channel, pitch: entity.get_state("sound_pitch").to_f32)
  end
end

CD.db.add_entity_proc("TileCollision") do |entity|
  entity.each_tile_collision do |collision|
    tile_width = collision.tileset.tile_width
    tile_height = collision.tileset.tile_height

    entity_width = entity.map_boxes[0].size.x
    entity_height = entity.map_boxes[0].size.y

    if collision.tile.get_flag("solid")
      if collision.other_position.x + tile_width // 2 > entity.aligned_position.x && (entity.aligned_position.y - collision.other_position.y - tile_height // 2).abs < entity_width
        entity.velocity.x = 0 if entity.velocity.x > 0
      end

      if collision.other_position.x + tile_width // 2 < entity.aligned_position.x && (entity.aligned_position.y - collision.other_position.y - tile_height // 2).abs < entity_width
        entity.velocity.x = 0 if entity.velocity.x < 0
      end

      if collision.other_position.y + tile_height // 2 > entity.aligned_position.y && (entity.aligned_position.x - collision.other_position.x - tile_width // 2).abs < entity_height
        entity.velocity.y = 0 if entity.velocity.y > 0
      end
      
      if collision.other_position.y + tile_height // 2 < entity.aligned_position.y && (entity.aligned_position.x - collision.other_position.x - tile_width // 2).abs < entity_height
        entity.velocity.y = 0 if entity.velocity.y < 0
      end
    end
  end
end

WIDTH = 1600
HEIGHT = 900

class CustomScene < CD::Scene
  def init
    map = add_map("Map1", tileset: CD::Tileset.from_json_file("example/ExampleTileset.json"))
    #map.content.load_from_array!(generate_test_map(width: 200, height: 200))
    map.content.load_from_text_file!("example/ExampleMap.txt")
    map.background_tile = 0
    map.z = 2
    map.pin

    texture_bg = CD.rm.load_texture("example/ExampleSky.png")
    bg = CD::Sprite.new
    bg.link_texture(texture_bg)
    bg.position = CD.xy(-100, -100)
    bg.parallax = CD.xy(0.1, 0.1)
    bg.render_rect = CD::Rect.new(width: 2000, height: 2000)
    bg.z = 1
    bg.pin

    CD.db.load_entity_type_from_file("example/ExampleEntityStateFigure.json")
    CD.db.load_entity_type_from_file("example/ExampleEntityStatePlayer.json")

    add_entity_group("PlayerGroup", auto_update: true, auto_physics: true, auto_events: true, auto_draw: true, capacity: 1)
    add_entity_group("FigureGroup", auto_update: true, auto_physics: true, auto_events: true, auto_draw: true, capacity: 5)

    add_entity(group: "PlayerGroup", type: "Player", position: CD.xy(600, -50))
    5.times do |i|
       add_entity(group: "FigureGroup", type: "Figure", position: CD.xy(25 + 100*i, -50), initial_param: i)
    end

    camera = CD::Camera.new
    camera.follow_entity(entity_groups["PlayerGroup"].get_entity(0), shift: CD.xy(-WIDTH/2 + 25, -HEIGHT/2 + 25))
    camera.z = 0
    camera.pin

    # TODO: Make it possible to load this from JSON
    CD.im.set_key_table_entry("action_key", [CD::Keyboard::K_SPACE])
    CD.im.set_key_table_entry("up", [CD::Keyboard::K_UP, CD::Keyboard::K_W])
    CD.im.set_key_table_entry("down", [CD::Keyboard::K_DOWN, CD::Keyboard::K_S])
    CD.im.set_key_table_entry("left", [CD::Keyboard::K_LEFT, CD::Keyboard::K_A])
    CD.im.set_key_table_entry("right", [CD::Keyboard::K_RIGHT, CD::Keyboard::K_D])
    CD.im.set_key_table_entry("fast_mode", [CD::Keyboard::K_L])

    self.collision_matrix.link(entity_groups["FigureGroup"])
    self.collision_matrix.link(entity_groups["FigureGroup"], maps["Map1"])
    self.collision_matrix.link(entity_groups["PlayerGroup"], entity_groups["FigureGroup"])
    self.collision_matrix.link(entity_groups["PlayerGroup"], maps["Map1"])
    
    Crystal2Day.grid_alignment = 5
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
      puts "R Position: #{entity_groups["PlayerGroup"].get_entity(0).position.inspect}"
      puts "A Position: #{entity_groups["PlayerGroup"].get_entity(0).aligned_position.inspect}"
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
        array[y][x] = 0 if rand < 0.5
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
