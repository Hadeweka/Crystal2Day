module Crystal2Day
  alias TileID = UInt32

  class MapContent
    getter width : UInt32 = 0
    getter height : UInt32 = 0
    getter tiles = [] of Array(TileID)

    def load_from_array!(array : Array(Array(TileID)))
      @height = array.size.to_u32
      width_obtained = false
      @tiles = Array(Array(TileID)).new(initial_capacity: @height)

      array.each do |line|
        if width_obtained
          Crystal2Day.error "Array has inconcistent sizes" if @width != line.size
        else
          @width = line.size.to_u32
          width_obtained = true
        end

        @tiles.push Array(TileID).new(initial_capacity: @width)

        line.each do |element|
          @tiles[-1].push element
        end
      end
    end
  end

  class Map < Crystal2Day::Drawable
    property content : MapContent = MapContent.new
    property tileset : Crystal2Day::Tileset = Crystal2Day::Tileset.new

    property drawing_rect : Crystal2Day::Rect = Crystal2Day::Rect.new(width: Crystal2Day.current_window.not_nil!.width, height: Crystal2Day.current_window.not_nil!.height)

    getter vertices = [] of LibSDL::Vertex

    property background_tile : TileID = 0u32

    VERTEX_SIGNATURE = [0, 1, 2, 0, 2, 3]

    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super()
    end

    def generate_vertices(view_width : UInt32, view_height : UInt32)
      @vertices = Array(LibSDL::Vertex).new(size: view_width * view_height * 6) {LibSDL::Vertex.new}
    end

    def reload_vertex_grid
      view_width = (drawing_rect.width / @tileset.tile_width).ceil.to_u32 + 1
      view_height = (drawing_rect.height / @tileset.tile_height).ceil.to_u32 + 1

      generate_vertices(view_width, view_height)

      pos_shift_x = @renderer.position_shift.x
      pos_shift_y = @renderer.position_shift.y

      exact_shift_x = @drawing_rect.x + @drawing_rect.width / 2 - pos_shift_x - (view_width - 1) * (@tileset.tile_width / 2) - 1
      exact_shift_y = @drawing_rect.y + @drawing_rect.height / 2 - pos_shift_y - (view_height - 1) * (@tileset.tile_height / 2) - 1

      n_tiles_x = @tileset.texture.width // @tileset.tile_width
      n_tiles_y = @tileset.texture.height // @tileset.tile_height

      0.upto(view_width - 1) do |x|
        0.upto(view_height - 1) do |y|
          exact_actual_x = x.to_f32 + exact_shift_x / @tileset.tile_width
          exact_actual_y = y.to_f32 + exact_shift_y / @tileset.tile_height

          actual_x = exact_actual_x.floor.to_i32
          actual_y = exact_actual_y.floor.to_i32

          invalid_tile = actual_x < 0 || actual_x.to_u32 >= @content.width || actual_y < 0 || actual_y.to_u32 >= @content.height

          tile_id = invalid_tile ? @background_tile : @content.tiles[actual_y][actual_x]

          actual_tile_id = tile_id  # TODO: Animations

          tx = actual_tile_id % n_tiles_x
          ty = actual_tile_id // n_tiles_x

          0u64.upto(5) do |c|
            dx = (c == 1 || c == 2 || c == 4) ? 1 : 0
            dy = (c == 2 || c == 4 || c == 5) ? 1 : 0

            vx = ((actual_x + dx) * @tileset.tile_width).to_f32 - @drawing_rect.x + pos_shift_x
            vy = ((actual_y + dy) * @tileset.tile_height).to_f32 - @drawing_rect.y + pos_shift_y

            vtx = (tx + dx) / n_tiles_x
            vty = (ty + dy) / n_tiles_y

            vertex_no = (x * view_height + y) * 6 + c
            new_vertex = LibSDL::Vertex.new(position: Crystal2Day::Coords.new(vx, vy).data, tex_coord: Crystal2Day::Coords.new(vtx, vty).data, color: Crystal2Day::Color.white.data)
            @vertices[vertex_no] = new_vertex
          end
        end
      end
    end

    def draw_directly
      reload_vertex_grid
      LibSDL.render_geometry(@tileset.texture.renderer_data, @tileset.texture.data, @vertices, @vertices.size, nil, 0)
    end
  end
end
