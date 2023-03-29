module Crystal2Day
  alias TileID = UInt32

  class MapContent
    getter width : UInt32 = 0
    getter height : UInt32 = 0
    getter tiles = [] of Array(TileID)

    def generate_test_map(width : UInt32, height : UInt32, with_rocks : Bool = false)
      @width = width
      @height = height
      0.upto(@height - 1) do |y|
        @tiles.push Array(TileID).new
        0.upto(@width - 1) do |x|
          if with_rocks
            @tiles[y].push(rand < 0.1 ? 6u32 : 0u32)
          else
            @tiles[y].push (rand(3).to_u32 + 1)
          end
        end
      end
    end
  end

  class Map < Crystal2Day::Drawable
    property content : MapContent = MapContent.new

    getter vertices = [] of LibSDL::Vertex

    # TODO: Put these in tilesets
    @texture : Crystal2Day::Texture
    @tile_width : UInt32 = 50u32
    @tile_height : UInt32 = 50u32

    property background_tile : TileID = 0u32

    VERTEX_SIGNATURE = [0, 1, 2, 0, 2, 3]

    def initialize
      super()
      @texture = Crystal2Day::Texture.new
    end

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end

    def generate_vertices(view_width : UInt32, view_height : UInt32)
      @vertices = Array(LibSDL::Vertex).new(size: view_width * view_height * 6) {LibSDL::Vertex.new}
    end

    def reload(drawing_rect : C2D::Rect)
      view_width = (drawing_rect.width / @tile_width).ceil.to_u32 + 1
      view_height = (drawing_rect.height / @tile_height).ceil.to_u32 + 1

      generate_vertices(view_width, view_height)

      exact_shift_x = drawing_rect.x - (view_width - 1) * (@tile_width / 2) - 1
      exact_shift_y = drawing_rect.y - (view_height - 1) * (@tile_height / 2) - 1

      n_tiles_x = @texture.width // @tile_width
      n_tiles_y = @texture.height // @tile_height

      0.upto(view_width - 1) do |x|
        0.upto(view_height - 1) do |y|
          exact_actual_x = x.to_f32 + exact_shift_x / @tile_width
          exact_actual_y = y.to_f32 + exact_shift_y / @tile_height

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

            vx = ((actual_x + dx) * @tile_width).to_f32 - drawing_rect.x + drawing_rect.width / 2
            vy = ((actual_y + dy) * @tile_height).to_f32 - drawing_rect.y + drawing_rect.height / 2

            vtx = (tx + dx) / n_tiles_x
            vty = (ty + dy) / n_tiles_y

            vertex_no = (x * view_height + y) * 6 + c
            new_vertex = LibSDL::Vertex.new(position: C2D::Coords.new(vx, vy).data, tex_coord: C2D::Coords.new(vtx, vty).data, color: C2D::Color.white.data)
            @vertices[vertex_no] = new_vertex
          end
        end
      end
    end

    def draw_directly
      LibSDL.render_geometry(@texture.renderer_data, @texture.data, @vertices, @vertices.size, nil, 0)
    end
  end
end
