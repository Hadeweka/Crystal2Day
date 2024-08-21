# Tile information for maps.
# These specify what exactly to draw when rendering a tile.
# Also, you can extend the `Tile` class for custom tile information.

module Crystal2Day
  class Tile
    FLAGS_INITIAL_CAPACITY = 16

    # Hard-coded options
    property name : String = ""
    property dummy : Bool = false # Marks a tile as being in the tileset for animation purposes only (NOTE: It still has an individual Tile ID!)
    property no_collision : Bool = false  # The tile will not be tested for any collisions, TODO: Do we need this here?
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

    property animated_tiles : Array(Tile) = Array(Tile).new(initial_capacity: INITIAL_CAPACITY)

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      @refs : Array(Anyolite::RbRef) = Array(Anyolite::RbRef).new(initial_capacity: INITIAL_CAPACITY)
    {% end %}

    def initialize
    end

    def initialize(pull : JSON::PullParser)
      pull.read_object do |key|
        case key
        when "texture"
          @texture = Crystal2Day.rm.load_texture(pull.read_string)
        when "tile_width"
          @tile_width = pull.read_int.to_u32
        when "tile_height"
          @tile_height = pull.read_int.to_u32
        when "tiles"
          pull.read_array do
            new_tile = Tile.new
            pull.read_object do |tile_property|
              case tile_property
              when "name"
                new_tile.name = pull.read_string
              when "dummy"
                new_tile.dummy = pull.read_bool
              when "no_collision"
                new_tile.no_collision = pull.read_bool
              when "animation_template"
                new_tile.animation_template = AnimationTemplate.from_json(pull.read_raw)
              else
                # TODO: Maybe add more options than bools?
                new_tile.set_flag(tile_property, pull.read_bool)
              end
            end
            add_tile(new_tile)
          end
        end
      end
    end

    def calculate_animated_tiles(time : UInt32)
      # TODO: Set animated_tiles array to relevant values
      # TODO: Parse this information from the Tiled files to the tilesets
      # TODO: Put this all together
    end

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
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        new_ref = Crystal2Day::Interpreter.generate_ref(tile)
        @refs.push new_ref
      {% end %}
      
      @tiles.push(tile)
    end

    def fill_with_default_tiles(number : UInt32)
      number.times {add_tile(Tile.new)}
    end
  
    def tiles
      @tiles
    end

    def load_from_tiled_file!(filename : String, given_texture : Texture? = nil)
      full_filename = Crystal2Day.convert_to_absolute_path(filename)

      parsed_tileset = Tiled.parse_tileset(full_filename)

      @tile_width = parsed_tileset.tile_width
      @tile_height = parsed_tileset.tile_height

      if given_texture
        @texture = given_texture
      else
        @texture = Crystal2Day.rm.load_texture(Crystal2Day.convert_to_absolute_path(parsed_tileset.image_file))
      end

      parsed_tileset.tile_count.times do |tile_id|
        new_tile = Tile.new
        
        new_tile.name = "T_#{tile_id}"

        parsed_tileset.tile_properties[tile_id].properties.each do |name, prop|
          if name == "no_collision"
            new_tile.no_collision = true
          elsif prop.is_a?(Bool)
            new_tile.set_flag(name, prop)
          else
            # Currently unsupported, might receive support in the future
          end
        end

        frame_time = nil
        parsed_tileset.tile_animations[tile_id].each do |tile_anim|
          if frame_time && tile_anim.duration != frame_time
            Crystal2Day.warning "Different tile animation frame times are currently not supported."
          else
            frame_time = tile_anim.duration if !frame_time
          end
        end
        
        # TODO: Add animations
        
        add_tile(new_tile)
      end
    end
  end
end
