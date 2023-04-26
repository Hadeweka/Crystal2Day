# A camera class, which affects all layers above it when drawn.
# It simply shifts all content above it by its position.

module Crystal2Day
  class Camera < Crystal2Day::Drawable
    property position : Crystal2Day::Coords = Crystal2Day.xy
    
    def initialize(@position : Crystal2Day::Coords = Crystal2Day.xy, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super()
    end

    def draw_directly(offset : Coords)
      @renderer.position_shift = (@position + offset) * (-1)
    end
  end
end