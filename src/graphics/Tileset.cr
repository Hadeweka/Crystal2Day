# Tile information for maps.
# These specify what exactly to draw when rendering a tile.
# Also, you can extend the `Tile` class for custom tile information.

module Crystal2Day
  class Tile
    @solid = false
  
    def initialize
    end
  
    def solid
      return @solid
    end
  
    def solid=(value : Bool = true)
      @solid = value
    end
  end

  class Tileset
    INITIAL_CAPACITY = 256

    getter texture : Crystal2Day::Texture = Crystal2Day::Texture.new
    property tile_width : UInt32 = 50u32
    property tile_height : UInt32 = 50u32
    @tiles : Array(Tile) = Array(Tile).new(initial_capacity: INITIAL_CAPACITY)

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end
  
    def get_tile(identification : Crystal2Day::TileID)
      @tiles[identification]? ? @tiles[identification] : Crystal2Day.error "Undefined tile with tile ID: #{identification}"
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