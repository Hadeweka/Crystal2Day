# The main module.
# This is globally accessible to allow for a cleaner syntax.
# You will most likely need this for running your game.

module Crystal2Day
  MAX_VOLUME = LibSDL::MIX_MAX_VOLUME

  class_property scene : Crystal2Day::Scene | Nil
  class_property next_scene : Crystal2Day::Scene | Bool | Nil
  class_property limiter : Crystal2Day::Limiter = Crystal2Day::Limiter.new
  class_getter windows : Array(Crystal2Day::Window) = [] of Crystal2Day::Window
  class_property clean_windows_on_scene_exit : Bool = true
  class_property game_data : Crystal2Day::GameData = Crystal2Day::GameData.new
  class_property physics_time_step : Float32 = 1.0
  class_property resource_manager : Crystal2Day::ResourceManager = Crystal2Day::ResourceManager.new

  @@current_window : Crystal2Day::Window?

  @@debug : Bool = false

  def self.rm
    resource_manager
  end

  def self.rm=(value)
    resource_manager = value
  end

  macro call_scene_routine(scene, name)
    %scene_temp = {{scene}}
    if %scene_temp.is_a?(Crystal2Day::Scene)
      %scene_temp.{{name.id}}
    else
      puts "WARNING: Scene variable {{scene}} is set to #{%scene_temp.inspect}"
    end
  end

  def self.run(debug : Bool = false)
    Crystal2Day.init(debug: debug)
    Crystal2Day::Interpreter.start
    Crystal2Day::Interpreter.expose_module_only(Crystal2Day)
    Crystal2Day::Interpreter.expose_class_property(Crystal2Day, game_data, Crystal2Day::GameData)
    Crystal2Day::Interpreter.expose_class_property(Crystal2Day, physics_time_step, Float32)
    Crystal2Day::Interpreter.expose_class_function(Crystal2Day, xy, [x : Float32 = 0.0f32, y : Float32 = 0.0f32])
    # TODO: Maybe just use Anyolite for the whole module
    Crystal2Day::Interpreter.expose_class(Crystal2Day::Coords, under: Crystal2Day)
    Crystal2Day::Interpreter.expose_class(Crystal2Day::Color, under: Crystal2Day)
    Crystal2Day::Interpreter.expose_class(Crystal2Day::Entity, under: Crystal2Day)
    Crystal2Day::Interpreter.expose_class(Crystal2Day::GameData, under: Crystal2Day)
    yield
    Crystal2Day::Interpreter.close
    Crystal2Day.quit
  end

  def self.main_routine
    @@limiter.set_update_routine do
      if current_scene = @@scene
        Crystal2Day.call_scene_routine(current_scene, :process_events)
        Crystal2Day.call_scene_routine(current_scene, :main_update)
      else
        Crystal2Day.error "Could not update without a scene"
      end

      if !@@next_scene
        if current_scene = @@scene
          Crystal2Day.call_scene_routine(current_scene, :exit_routine)
        else
          Crystal2Day.error "Could not exit empty scene properly"
        end

        @@scene = nil
      elsif @@next_scene != true
        if current_scene = @@scene
          Crystal2Day.call_scene_routine(current_scene, :exit_routine)
        else
          Crystal2Day.error "Could not exit empty scene properly"
        end

        @@scene = @@next_scene.as?(Crystal2Day::Scene).not_nil!
        @@next_scene = true
        Crystal2Day.call_scene_routine(@@scene, :init)
      end
    end

    @@limiter.set_draw_routine do
      if current_scene = @@scene
        Crystal2Day.call_scene_routine(current_scene, :main_draw)
      else
        Crystal2Day.error "Could not draw without a scene"
      end
    end

    @@limiter.set_gc_routine do
      GC.collect
    end

    Crystal2Day.call_scene_routine(@@scene, :init)
    @@next_scene = true

    while @@next_scene
      break if !@@limiter.tick
    end
  end

  def self.init(debug : Bool = false)
    if LibSDL.init(LibSDL::INIT_EVERYTHING) != 0
      Crystal2Day.error "Could not initialize SDL"
    end
    
    if LibSDL.set_hint(LibSDL::HINT_RENDER_SCALE_QUALITY, "1") == 0
      Crystal2Day.warning "Linear texture filtering not enabled!"
    end

    img_flags = LibSDL::IMGInitFlags::IMG_INIT_PNG
    if (LibSDL.img_init(img_flags) | img_flags.to_i) == 0
      Crystal2Day.error "Could not initialize SDL_image"
    end

    if LibSDL.ttf_init == -1
      Crystal2Day.error "Could not initialize SDL_ttf"
    end

    if LibSDL.mix_open_audio(44100, LibSDL::MIX_DEFAULT_FORMAT, 2, 2048) < 0
      Crystal2Day.error "Could not initialize SDL_mixer"
    end

    @@debug = true if debug
  end

  # NOTE: FPS tracking is disabled by default. Calling this function will enable it.
  def self.get_fps
    @@limiter.current_draw_fps
  end

  def self.current_window
    if window = @@current_window
      window
    else
      Crystal2Day.error "No window available"
    end
  end

  def self.current_window_if_any
    @@current_window
  end

  def self.current_window=(window : Crystal2Day::Window?)
    @@current_window = window
  end

  def self.register_window(window : Crystal2Day::Window)
    @@windows.push(window) unless @@windows.includes?(window)
  end

  def self.unregister_window(window : Crystal2Day::Window)
    @@windows.delete(window)
  end

  def self.for_window(window : Crystal2Day::Window)
    previous_window = @@current_window
    @@current_window = window
    if win = @@current_window
      if win.open? 
        yield nil
      end
    end
    @@current_window = previous_window
  end

  def self.with_z_offset(z_offset : Number)
    if win = @@current_window
      win.z_offset += z_offset.to_u8
      yield nil
      win.z_offset -= z_offset.to_u8
    end
  end

  def self.with_view(view : Crystal2Day::View, z_offset : Number = 0u8)
    if win = @@current_window
      self.with_z_offset(z_offset) do
        win.draw view
        yield nil
      end
    end
  end

  def self.with_pinned_view(view : Crystal2Day::View, z_offset : Number = 0u8)
    if win = @@current_window
      self.with_z_offset(z_offset) do
        win.pin view
        yield nil
      end
    end
  end

  def self.get_mouse_focused_window
    raw_window = LibSDL.get_mouse_focus

    @@windows.each do |window|
      if window.data == raw_window
        return window
      end
    end

    return nil
  end

  def unpin_all
    if window = @@current_window
      window.unpin_all
    else
      Crystal2Day.error "Could not unpin from closed or invalid window"
    end
  end

  def self.quit
    LibSDL.mix_quit
    LibSDL.ttf_quit
    LibSDL.img_quit
    LibSDL.quit
  end

  def self.error(message : String)
    sdl_error = String.new(LibSDL.get_error)
    raise "#{message}" + (sdl_error.empty? ? "" : " (SDL Error: #{sdl_error})")
  end

  def self.check_for_internal_errors
    sdl_error = String.new(LibSDL.get_error)
    if sdl_error.empty?
      nil
    else
      sdl_error
    end
  end

  def self.debug?
    @@debug
  end

  def self.debug_log(message : String)
    puts "DEBUG: #{message}" if Crystal2Day.debug?
  end

  def self.log(message : String)
    puts "LOG: #{message}"
  end

  def self.warning(message : String)
    puts "WARNING: #{message}"
  end

  def self.poll_events
    while LibSDL.poll_event(out raw_event) != 0
      yield Crystal2Day::Event.new(raw_event)
    end
  end
end
