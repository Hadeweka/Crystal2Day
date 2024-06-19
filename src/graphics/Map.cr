# Two map classes, one for the actual map data and one for the rendering.

module Crystal2Day
  alias TileID = UInt32

  class MapCombo
    getter total_width_in_chunks : UInt32 = 0
    getter total_height_in_chunks : UInt32 = 0
    getter chunk_width : UInt32 = 0
    getter chunk_height : UInt32 = 0
    getter number_of_maps : UInt32 = 0
    getter chunks : Array(Array(UInt32)) = [] of Array(UInt32)
    getter map_list : Array(MapContent) = [] of MapContent
    getter map_starting_points : Array(Tuple(UInt32, UInt32)) = [] of Tuple(UInt32, UInt32)

    property background_tile : TileID = 0u32  # NOTE: This is a background tile for when no chunk is found

    def width
      @total_width_in_chunks * @chunk_width
    end

    def height
      @total_height_in_chunks * @chunk_height
    end

    def get_tile(x : Int32, y : Int32)
      chunk_x = x // chunk_width
      chunk_y = y // chunk_height
      if chunk_x < 0 || chunk_y >= @total_width_in_chunks || chunk_y < 0 || chunk_y >= @total_height_in_chunks
        return @background_tile
      else
        chunk = @chunks[chunk_y][chunk_x]
        if chunk == 0
          return @background_tile
        else
          relative_x = x - @map_starting_points[chunk - 1][0] * @chunk_width
          relative_y = y - @map_starting_points[chunk - 1][1] * @chunk_height
          return @map_list[chunk - 1].get_tile(relative_x, relative_y)
        end
      end
    end

    def load_from_text_file!(filename : String)
      full_filename = Crystal2Day.convert_to_absolute_path(filename)

      line_number = 0
      File.each_line(full_filename) do |line|
        if line_number == 0
        elsif line_number == 1
          @total_width_in_chunks = line.split[0].to_u32
          @total_height_in_chunks = line.split[1].to_u32
          @chunk_width = line.split[2].to_u32
          @chunk_height = line.split[3].to_u32
          @number_of_maps = line.split[4].to_u32
          @chunks = Array(Array(UInt32)).new(initial_capacity: @total_height_in_chunks)
          @map_list = Array(MapContent).new(initial_capacity: @number_of_maps)
          @map_starting_points = Array(Tuple(UInt32, UInt32)).new(size: @number_of_maps, value: {@total_width_in_chunks, @total_height_in_chunks})
        elsif line_number < 2 + @total_height_in_chunks
          current_chunk_y = line_number - 2
          split_line = line.split
          @chunks.push Array(UInt32).new(initial_capacity: @total_width_in_chunks)
          split_line.each_with_index do |split_part, current_chunk_x|
            map_index = split_part.to_u32
            @chunks[-1].push map_index
            if map_index != 0
              old_starting_point = @map_starting_points[map_index - 1]
              lowest_starting_x = {old_starting_point[0], current_chunk_x}.min.to_u32
              lowest_starting_y = {old_starting_point[1], current_chunk_y}.min.to_u32
              @map_starting_points[map_index - 1] = {lowest_starting_x, lowest_starting_y}
            end
          end
        else
          unless line.strip.empty?
            @map_list.push MapContent.new
            @map_list[-1].load_from_text_file!(line.strip)
          end
        end
        line_number += 1
      end
    end
  end

  class MapContent
    getter width : UInt32 = 0
    getter height : UInt32 = 0
    getter tiles = [] of Array(TileID)

    property background_tile : TileID = 0u32

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

    def get_tile(x : Int32, y : Int32)
      invalid_tile = x < 0 || x.to_u32 >= @width || y < 0 || y.to_u32 >= @height
      invalid_tile ? @background_tile : @tiles[y][x]
    end

    def load_from_text_file!(filename : String)
      full_filename = Crystal2Day.convert_to_absolute_path(filename)

      line_number = 0
      File.each_line(full_filename) do |line|
        if line_number == 0
        elsif line_number == 1
          @width = line.split[0].to_u32
          @height = line.split[1].to_u32
          @tiles = Array(Array(TileID)).new(initial_capacity: @height)
        else
          split_line = line.split
          @tiles.push Array(TileID).new(initial_capacity: @width)
          split_line.each do |split_part|
            @tiles[-1].push TileID.new(split_part.to_u32)
          end
        end
        line_number += 1
      end
    end
  end

  class Map < Crystal2Day::Drawable
    property content : MapContent | MapCombo = MapContent.new
    property tileset : Crystal2Day::Tileset = Crystal2Day::Tileset.new

    property drawing_rect : Crystal2Day::Rect = Crystal2Day::Rect.new(width: Crystal2Day.current_window.width, height: Crystal2Day.current_window.height)

    getter vertices = [] of LibSDL::Vertex

    VERTEX_SIGNATURE = [0, 1, 2, 0, 2, 3]

    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      super()
    end

    def set_as_stream!
      @content = MapCombo.new
    end

    def check_for_collision_with(other : EntityGroup | Map)
      if other.is_a?(Map)
        Crystal2Day.error "Map-Map collisions are not implemented."
      else
        # No need to implement this twice
        other.check_for_collision_with(self)
      end
    end

    def generate_vertices(view_width : UInt32, view_height : UInt32)
      @vertices = Array(LibSDL::Vertex).new(size: view_width * view_height * 6) {LibSDL::Vertex.new}
    end

    def reload_vertex_grid(offset : Coords)
      view_width = (drawing_rect.width / @tileset.tile_width).ceil.to_u32 + 1
      view_height = (drawing_rect.height / @tileset.tile_height).ceil.to_u32 + 1

      generate_vertices(view_width, view_height)

      pos_shift_x = @renderer.position_shift.x + offset.x
      pos_shift_y = @renderer.position_shift.y + offset.y

      exact_shift_x = @drawing_rect.x + @drawing_rect.width / 2 - pos_shift_x - (view_width - 1) * (@tileset.tile_width / 2) - 1
      exact_shift_y = @drawing_rect.y + @drawing_rect.height / 2 - pos_shift_y - (view_height - 1) * (@tileset.tile_height / 2) - 1

      n_tiles_x = @tileset.texture.width // @tileset.tile_width
      n_tiles_y = @tileset.texture.height // @tileset.tile_height

      0.upto(view_width - 1) do |x|
        0.upto(view_height - 1) do |y|
          exact_actual_x = x.to_f32 + exact_shift_x / @tileset.tile_width
          exact_actual_y = y.to_f32 + exact_shift_y / @tileset.tile_height

          # NOTE: The rounding here is to prevent floating point errors for now
          # This should work, but maybe there's a better solution
          actual_x = exact_actual_x.round(2).floor.to_i32
          actual_y = exact_actual_y.round(2).floor.to_i32

          tile_id = @content.get_tile(actual_x, actual_y)

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

    def draw_directly(offset : Coords)
      reload_vertex_grid(offset)
      LibSDL.render_geometry(@tileset.texture.renderer_data, @tileset.texture.data, @vertices, @vertices.size, nil, 0)
    end
  end
end
