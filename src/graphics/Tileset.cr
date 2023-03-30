module Crystal2Day
  class Tile
    @solid = false
    @animation_frame = false
  
    # TODO: These currently don't do anything
    @index_of_first_animation_frame : Crystal2Day::TileID = 0
    @index_of_first_other_animation_frame : Crystal2Day::TileID = 0
    @number_of_animation_frames : UInt32 = 0
    @time_per_animation_frame : UInt32 = 0
  
    def initialize
    end
  
    def solid
      return @solid
    end
  
    def is_animation_frame?
      return @animation_frame
    end
  
    def solid=(value : Bool = true)
      @solid = value
    end
  
    def get_animation_frame(frame_counter : UInt32)
      animation_cycle = @number_of_animation_frames * @time_per_animation_frame
      animation_time = frame_counter % animation_cycle
      animation_index = animation_time // @time_per_animation_frame
  
      if animation_index == 0
        return @index_of_first_animation_frame
      else
        return @index_of_first_other_animation_frame + animation_index - 1
      end
    end
  
    def set_animation(@index_of_first_animation_frame : Crystal2Day::TileID, @index_of_first_other_animation_frame : Crystal2Day::TileID, @number_of_animation_frames : UInt32, @time_per_animation_frame : UInt32)
      @animation_frame = true
    end
  end

  class Tileset
    getter texture : Crystal2Day::Texture = Crystal2Day::Texture.new
    property tile_width : UInt32 = 50u32
    property tile_height : UInt32 = 50u32
    @tiles : Array(Tile) = Array(Tile).new(initial_capacity: 1000)

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end
  
    def get_tile(identification : Crystal2Day::TileID)
      @tiles[identification]? ? @tiles[identification] : C2D.error "Undefined tile with tile ID: #{identification}"
    end
  
    def size
      @tiles.size
    end
  
    def add_tile(tile : Tile)
      @tiles.push(tile)
    end

    def fill_with_default_tiles(number : UInt32)
      number.times {add_tile(Tile.new)}
    end
  
    def tiles
      @tiles
    end
  end
end