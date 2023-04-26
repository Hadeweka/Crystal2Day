# A collection of drawable shapes.
# You can also implement your own shapes, as long as you specifiy how to draw them.

module Crystal2Day
  abstract class Shape < Crystal2Day::Drawable
    property position : Crystal2Day::Coords = Crystal2Day.xy
    property color : Crystal2Day::Color = Crystal2Day::Color.black

    @renderer : Crystal2Day::Renderer
  
    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super()
    end
  end

  class ShapePoint < Shape
    def initialize(position : Crystal2Day::Coords = Crystal2Day.xy, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @position = position
    end

    def draw_directly(offset : Coords)
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      LibSDL.render_draw_point_f(@renderer.data, @position.x + @renderer.position_shift.x + offset.x, @position.y + @renderer.position_shift.y + offset.y)
    end
  end

  class ShapeLine < Shape
    property direction : Crystal2Day::Coords

    def initialize(direction : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @direction = direction
      @position = position
    end

    def draw_directly(offset : Coords)
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      draw_x = @position.x + @renderer.position_shift.x + offset.x
      draw_y =  @position.y + @renderer.position_shift.y + offset.y
      draw_end_x = @position.x + @direction.x + @renderer.position_shift.x + offset.x
      draw_end_y = @position.y + @direction.y + @renderer.position_shift.y + offset.y
      LibSDL.render_draw_line_f(@renderer.data, draw_x, draw_y, draw_end_x, draw_end_y)
    end
  end

  class ShapeBox < Shape
    property size : Crystal2Day::Coords

    property filled : Bool = false

    def initialize(size : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @size = size
      @position = position
    end

    def draw_directly(offset : Coords)
      LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
      rect = LibSDL::FRect.new(x: @position.x + @renderer.position_shift.x + offset.x, y: @position.y + @renderer.position_shift.y + offset.y, w: @size.x, h: @size.y)
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

    property number_of_render_iterations : UInt32 = 32
    property filled : Bool = false

    def initialize(radius : Float32, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @radius = radius
      @position = position
    end

    def draw_directly(offset : Coords)
      # TODO: Optimize this if necessary

      segment_angle = 2.0 * Math::PI / (number_of_render_iterations + 1)
      base_circle = Array(Crystal2Day::Coords).new(size: number_of_render_iterations + 1) do |i|
        cos_angle = Math.cos(segment_angle * i)
        sin_angle = Math.sin(segment_angle * i)
        Crystal2Day.xy(@radius * cos_angle, @radius * sin_angle)
      end

      center_position = @position + @renderer.position_shift + offset

      if @filled
        vertices = Array(LibSDL::Vertex).new(initial_capacity: (number_of_render_iterations + 1) * 4 * 3)

        0.upto(3) do |segment_id|
          0.upto(number_of_render_iterations) do |i|
            index = 3 * segment_id * i
            vertices.push LibSDL::Vertex.new(position: (center_position + base_circle[i]).data, color: @color.data)
            vertices.push LibSDL::Vertex.new(position: (center_position + base_circle[(i + 1) % base_circle.size]).data, color: @color.data)
            vertices.push LibSDL::Vertex.new(position: center_position.data, color: @color.data)
          end
        end

        LibSDL.render_geometry(@renderer.data, nil, vertices, vertices.size, nil, 0)
      else
        LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)

        0.upto(number_of_render_iterations) do |i|
          vx1 = (center_position + base_circle[i]).x
          vy1 = (center_position + base_circle[i]).y
          vx2 = (center_position + base_circle[(i + 1) % (number_of_render_iterations + 1)]).x
          vy2 = (center_position + base_circle[(i + 1) % (number_of_render_iterations + 1)]).y
          LibSDL.render_draw_line_f(@renderer.data, vx1, vy1, vx2, vy2)
        end
      end
    end
  end

  class ShapeTriangle < Shape
    property side_1 : Crystal2Day::Coords
    property side_2 : Crystal2Day::Coords

    property filled : Bool = false

    def self.from_vertices(vertex_0 : Crystal2Day::Coords, vertex_1 : Crystal2Day::Coords, vertex_2 : Crystal2Day::Coords, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
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

    def initialize(side_1 : Crystal2Day::Coords, side_2 : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @side_1 = side_1
      @side_2 = side_2
      @position = position
    end

    def draw_directly(offset : Coords)
      if @filled
        sdl_vertex_0 = LibSDL::Vertex.new(position: (vertex_0 + @renderer.position_shift).data, color: @color.data)
        sdl_vertex_1 = LibSDL::Vertex.new(position: (vertex_1 + @renderer.position_shift).data, color: @color.data)
        sdl_vertex_2 = LibSDL::Vertex.new(position: (vertex_2 + @renderer.position_shift).data, color: @color.data)
        vertices = [sdl_vertex_0, sdl_vertex_1, sdl_vertex_2]
        LibSDL.render_geometry(@renderer.data, nil, vertices, 3, nil, 0)
      else
        LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)
        shift_x = @renderer.position_shift.x + offset.x
        shift_y = @renderer.position_shift.y + offset.y
        LibSDL.render_draw_line_f(@renderer.data, vertex_0.x + shift_x, vertex_0.y + shift_y, vertex_1.x + shift_x, vertex_1.y + shift_y)
        LibSDL.render_draw_line_f(@renderer.data, vertex_1.x + shift_x, vertex_1.y + shift_y, vertex_2.x + shift_x, vertex_2.y + shift_y)
        LibSDL.render_draw_line_f(@renderer.data, vertex_2.x + shift_x, vertex_2.y + shift_y, vertex_0.x + shift_x, vertex_0.y + shift_y)
      end
    end
  end

  class ShapeEllipse < Shape
    property semiaxes : Crystal2Day::Coords

    property number_of_render_iterations : UInt32 = 32
    property filled : Bool = false

    def initialize(semiaxes : Crystal2Day::Coords, position : Crystal2Day::Coords = Crystal2Day.xy, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super(renderer)
      @semiaxes = semiaxes
      @position = position
    end

    def draw_directly(offset : Coords)
      # TODO: Optimize this if necessary
      # TODO: Put together circle and ellipse routines

      segment_angle = 2.0 * Math::PI / (number_of_render_iterations + 1)
      base_ellipse = Array(Crystal2Day::Coords).new(size: number_of_render_iterations + 1) do |i|
        cos_angle = Math.cos(segment_angle * i)
        sin_angle = Math.sin(segment_angle * i)
        Crystal2Day.xy(@semiaxes.x * cos_angle, @semiaxes.y * sin_angle)
      end

      center_position = @position + @renderer.position_shift + offset

      if @filled
        vertices = Array(LibSDL::Vertex).new(initial_capacity: (number_of_render_iterations + 1) * 4 * 3)

        0.upto(3) do |segment_id|
          0.upto(number_of_render_iterations) do |i|
            index = 3 * segment_id * i
            vertices.push LibSDL::Vertex.new(position: (center_position + base_ellipse[i]).data, color: @color.data)
            vertices.push LibSDL::Vertex.new(position: (center_position + base_ellipse[(i + 1) % base_ellipse.size]).data, color: @color.data)
            vertices.push LibSDL::Vertex.new(position: center_position.data, color: @color.data)
          end
        end

        LibSDL.render_geometry(@renderer.data, nil, vertices, vertices.size, nil, 0)
      else
        LibSDL.set_render_draw_color(@renderer.data, @color.r, @color.g, @color.b, @color.a)

        0.upto(number_of_render_iterations) do |i|
          vx1 = (center_position + base_ellipse[i]).x
          vy1 = (center_position + base_ellipse[i]).y
          vx2 = (center_position + base_ellipse[(i + 1) % (number_of_render_iterations + 1)]).x
          vy2 = (center_position + base_ellipse[(i + 1) % (number_of_render_iterations + 1)]).y
          LibSDL.render_draw_line_f(@renderer.data, vx1, vy1, vx2, vy2)
        end
      end
    end
  end
end