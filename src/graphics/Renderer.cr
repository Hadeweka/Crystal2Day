module Crystal2Day
  class Renderer
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::Renderer))

    @current_view : Crystal2Day::View = Crystal2Day::View.new
    getter original_view : Crystal2Day::View = Crystal2Day::View.new

    def initialize
    end

    # TODO: Put flags in Crystal2Day module
    def create!(from : Crystal2Day::Window, flags : LibSDL::RendererFlags = LibSDL::RendererFlags::RENDERER_ACCELERATED)
      free
      @data = LibSDL.create_renderer(from.data, -1, flags)
      @original_view = get_bound_view
      @current_view = get_bound_view
    end

    def get_bound_view
      LibSDL.render_get_viewport(data, out rect)
      Crystal2Day::View.new(rect, self)
    end

    def view
      @current_view
    end

    def view=(value : Crystal2Day::View)
      @current_view = value
      LibSDL.render_set_viewport(data, value.raw_data_ptr)
    end

    def reset_view
      self.view = self.original_view
    end

    def free
      if @data
        LibSDL.destroy_renderer(data)
        @data = nil
      end
    end

    def finalize
      free
    end
  end
end
