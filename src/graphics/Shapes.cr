module Crystal2Day
  abstract class Shape < Crystal2Day::Drawable
    property position : Crystal2Day::Coords = Crystal2Day.xy
    property color : Crystal2Day::Color = Crystal2Day::Color.black

    @renderer : Crystal2Day::Renderer
  
    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super()
    end
  end

  class ShapePoint < Shape
    def initialize(position : Crystal2Day::Coords = Crystal2Day.xy, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @position = position
    end

    def draw_directly
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      LibSDL.render_draw_point_f(@renderer.data, @position.x, @position.y)
    end
  end

  class ShapeLine < Shape
    property direction : Crystal2Day::Coords

    def initialize(direction : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @direction = direction
      @position = position
    end

    def draw_directly
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      LibSDL.render_draw_line_f(@renderer.data, @position.x, @position.y, @position.x + @direction.x, @position.y + @direction.y)
    end
  end

  class ShapeBox < Shape
    property size : Crystal2Day::Coords
    property filled : Bool = false

    def initialize(size : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @size = size
      @position = position
    end

    def draw_directly
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      rect = LibSDL::FRect.new(x: @position.x, y: @position.y, w: @size.x, h: @size.y)
      # NOTE: A pointer is passed, but since its contents will be copied immediately, there should be no issues
      if @filled
        LibSDL.render_fill_rect_f(@renderer.data, pointerof(rect))
      else
        LibSDL.render_draw_rect_f(@renderer.data, pointerof(rect))
      end
    end
  end

  class ShapeCircle < Shape
    property radius : Float32

    def initialize(radius : Float32, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @radius = radius
      @position = position
    end

    def draw_directly
      # TODO
    end
  end

  class ShapeTriangle < Shape
    property side_1 : Crystal2Day::Coords
    property side_2 : Crystal2Day::Coords

    def self.from_vertices(vertex_0 : Crystal2Day::Coords, vertex_1 : Crystal2Day::Coords, vertex_2 : Crystal2Day::Coords, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      self.new(vertex_1 - vertex_0, vertex_2 - vertex_0, position: vertex_0, renderer: renderer)
    end

    def get_vertex(number : Int)
      case number
      when 0
        @position
      when 1
        @position + @side_1
      when 2
        @position + @side_2
      else
        Crystal2Day.error "Invalid index for triangle vertices: #{number}"
      end
    end

    def set_vertex(number : Int, value : Crystal2Day::Coords)
      case number
      when 0
        @position = value
      when 1
        @side_1 = value - @position
      when 2
        @side_2 = value - @position
      else
        Crystal2Day.error "Invalid index for triangle vertices: #{number}"
      end
    end

    def vertex_0
      @position
    end

    def vertex_1
      @position + @side_1
    end

    def vertex_2
      @position + @side_2
    end

    def vertex_0=(value : Crystal2Day::Coords)
      @position = value
    end

    def vertex_1=(value : Crystal2Day::Coords)
      @side_1 = value - @position
    end

    def vertex_2=(value : Crystal2Day::Coords)
      @side_2 = value - @position
    end

    def initialize(side_1 : Crystal2Day::Coords, side_2 : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @side_1 = side_1
      @side_2 = side_2
      @position = position
    end

    def draw_directly
      # TODO
    end
  end

  class ShapeEllipse < Shape
    property semiaxes : Crystal2Day::Coords

    def initialize(semiaxes : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
      @semiaxes = semiaxes
      @position = position
    end

    def draw_directly
      # TODO
    end
  end
end