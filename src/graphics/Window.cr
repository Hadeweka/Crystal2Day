# The window class.
# You can even create multiples of these (Crystal2Day keeps track of them for you).

module Crystal2Day
  class Window
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::Window))

    property z_offset : UInt8 = 0

    getter renderer : Crystal2Day::Renderer = Crystal2Day::Renderer.new
    getter render_queue : Crystal2Day::RenderQueue = Crystal2Day::RenderQueue.new

    getter width : UInt32
    getter height : UInt32
    getter title : String
    getter fullscreen : Bool

    property resource_manager : Crystal2Day::ResourceManager = Crystal2Day::ResourceManager.new

    def initialize(title : String, w : Int, h : Int, x : Int = LibSDL::WINDOWPOS_UNDEFINED, y : Int = LibSDL::WINDOWPOS_UNDEFINED, fullscreen : Bool = false, set_as_current : Bool = true)
      window_flags = fullscreen ? LibSDL::WindowFlags::WINDOW_SHOWN | LibSDL::WindowFlags::WINDOW_FULLSCREEN : LibSDL::WindowFlags::WINDOW_SHOWN
      @data = LibSDL.create_window(title, x, y, w, h, window_flags)
      Crystal2Day.error "Could not create window with title \"#{title}\"" unless @data

      @width = w.to_u32
      @height = h.to_u32
      @title = title

      @fullscreen = fullscreen

      renderer_flags = LibSDL::RendererFlags::RENDERER_ACCELERATED
      @renderer.create!(self, renderer_flags)
      Crystal2Day.error "Could not create renderer" unless @renderer.data?

      @resource_manager.renderer = @renderer

      Crystal2Day.current_window = self if set_as_current
      Crystal2Day.register_window(self)
    end

    def width=(value : Int)
      @width = value
      LibSDL.set_window_size(data, @width, @height)
    end

    def height=(value : Int)
      @height = value
      LibSDL.set_window_size(data, @width, @height)
    end

    def title=(value : String)
      @title = value
      LibSDL.set_window_title(data, value)
    end

    def fullscreen=(value : Bool)
      @fullscreen = value
      window_flags = @fullscreen ? LibSDL::WindowFlags::WINDOW_SHOWN | LibSDL::WindowFlags::WINDOW_FULLSCREEN : LibSDL::WindowFlags::WINDOW_SHOWN
      LibSDL.set_window_fullscreen(data, window_flags)
    end 

    def open?
      data?
    end

    def position
      LibSDL.get_window_position(data, out x, out y)
      Crystal2Day::Coords.new(x, y)
    end

    def position=(coords : Crystal2Day::Coords)
      LibSDL.set_window_position(data, coords.x, coords.y)
    end

    def clear
      LibSDL.set_render_draw_color(@renderer.data, 0xFF, 0xFF, 0xFF, 0xFF)
      LibSDL.render_clear(@renderer.data)
    end

    def draw(obj : Crystal2Day::Drawable, offset : Coords = Crystal2Day.xy)
      @render_queue.add(obj, @z_offset + obj.z, offset)
    end

    def pin(obj : Crystal2Day::Drawable, offset : Coords = Crystal2Day.xy)
      @render_queue.add_static(obj, @z_offset + obj.z, offset)
    end

    def unpin(obj : Crystal2Day::Drawable, offset : Coords = Crystal2Day.xy)
      @render_queue.delete_static(obj, @z_offset + obj.z, offset)
    end

    def unpin_all
      @render_queue.delete_static_content
    end

    def render_and_display
      @renderer.reset
      @render_queue.draw
      LibSDL.render_present(@renderer.data)
    end

    def close
      Crystal2Day.current_window = nil if Crystal2Day.current_window_if_any == self
      Crystal2Day.unregister_window(self)
      @renderer.free
      LibSDL.destroy_window(data)
      @data = nil
    end

    def finalize
      unpin_all
      close
    end
  end
end
