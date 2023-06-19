# Tile information for maps.
# These specify what exactly to draw when rendering a tile.
# Also, you can extend the `Tile` class for custom tile information.

module Crystal2Day
  class Tile
    FLAGS_INITIAL_CAPACITY = 16

    # Hard-coded options
    property dummy : Bool = false # Marks a tile as being in the tileset for animation purposes only (NOTE: It still has an individual Tile ID!)
    property no_collision : Bool = false  # The tile will not be tested for any collisions
    property animation_template : Crystal2Day::AnimationTemplate = Crystal2Day::AnimationTemplate.new # TODO: Implement this

    @flags = Hash(String, Bool).new(initial_capacity: FLAGS_INITIAL_CAPACITY)
    # TODO: More options in other data formats
  
    def initialize
    end

    def get_flag(name : String, default_value : Bool = false)
      @flags[name]? ? @flags[name] : default_value
    end

    def set_flag(name : String, value : Bool = true)
      @flags[name] = value
    end
  end

  class Tileset
    INITIAL_CAPACITY = 256

    getter texture : Crystal2Day::Texture = Crystal2Day::Texture.new
    property tile_width : UInt32 = 50u32
    property tile_height : UInt32 = 50u32
    @tiles : Array(Tile) = Array(Tile).new(initial_capacity: INITIAL_CAPACITY)

    # TODO: Load tiles from JSON file

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