module Crystal2Day
  class Camera < Crystal2Day::Drawable
    property position : Crystal2Day::Coords = Crystal2Day.xy
    
    def initialize(@position : Crystal2Day::Coords = Crystal2Day.xy, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super()
    end

    def draw_directly
      @renderer.position_shift = @position * (-1)
    end
  end
end