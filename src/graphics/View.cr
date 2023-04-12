# A drawable object, which specifies a viewport for all objects above it.
# This allows for minimaps or split screens.

module Crystal2Day
  class View < Crystal2Day::Drawable
    @data : LibSDL::Rect
    @renderer : Crystal2Day::Renderer?

    def initialize(rect : Crystal2Day::Rect, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super()
      @data = LibSDL::Rect.new(x: rect.x, y: rect.y, w: rect.width, h: rect.height)
    end

    def x
      @data.x
    end

    def x=(value : Number)
      @data.x = value
    end

    def y
      @data.y
    end

    def y=(value : Number)
      @data.y = value
    end
    
    def width
      @data.w
    end

    def width=(value : Number)
      @data.w = value
    end

    def height
      @data.h
    end

    def height=(value : Number)
      @data.h = value
    end

    def initialize
      @data = LibSDL::Rect.new
    end

    def initialize(raw_rect : LibSDL::Rect, @renderer : Crystal2Day::Renderer)
      super()
      @data = raw_rect
    end

    def draw_directly
      @renderer.not_nil!.view = self
    end

    def raw_data_ptr
      pointerof(@data)
    end
  end
end
