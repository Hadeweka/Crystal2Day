# The renderer class, responsible for actual drawing.
# This is mostly an internal class.

module Crystal2Day
  class Renderer
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::Renderer))

    @current_view : Crystal2Day::View = Crystal2Day::View.new
    getter original_view : Crystal2Day::View = Crystal2Day::View.new
    property position_shift : Crystal2Day::Coords = Crystal2Day.xy

    def initialize
    end

    # TODO: Put flags in Crystal2Day module
    def create!(from : Crystal2Day::Window)
      free
      @data = LibSDL.create_renderer(from.data, nil)
      @original_view = get_bound_view
      @current_view = get_bound_view
    end

    def create!(from : Crystal2Day::RenderSurface)
      free
      @data = LibSDL.create_software_renderer(from.data)
      @original_view = get_bound_view
      @current_view = get_bound_view
    end

    def get_bound_view
      LibSDL.get_render_viewport(data, out rect)
      Crystal2Day::View.new(rect, self)
    end

    def view
      @current_view
    end

    def view=(value : Crystal2Day::View)
      @current_view = value
      LibSDL.set_render_viewport(data, value.raw_data_ptr)
    end

    def reset_view
      self.view = self.original_view
    end

    def reset_shift
      @position_shift = Crystal2Day.xy
    end

    def reset
      reset_view
      reset_shift
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
