module Crystal2Day
  struct CollisionReference
    enum Kind : UInt8
      EMPTY
      ENTITY
      TILE
    end
    
    property kind : Kind = Kind::EMPTY
    property other_object : Entity | Tile | Nil = nil
    property other_position : Coords = Crystal2Day.xy
    @tileset : Tileset? = nil

    def initialize(kind : Kind, other_object : Entity | Tile | Nil = nil, other_position : Coords = Crystal2Day.xy, tileset : Tileset? = nil)
      @kind = kind
      @other_object = other_object
      @other_position = other_position
      @tileset = tileset
    end

    def tileset
      @tileset.not_nil!
    end

    def tileset=(value : Tileset?)
      @tileset = value
    end

    def with_tile?
      @kind == Kind::TILE
    end

    def with_entity?
      @kind = Kind::ENTITY
    end

    def tile
      if with_tile?
        other_object.as(Tile)
      else
        Crystal2Day.error "Collision reference is not for a tile"
      end
    end

    def entity
      if with_entity?
        other_object.as(Entity)
      else
        Crystal2Day.error "Collision reference is not for an entity"
      end
    end

    def inspect
      "Kind: #{@kind}, with: #{other_object}"
    end
  end
end
