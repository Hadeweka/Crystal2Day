module Crystal2Day
  struct CollisionReference
    enum Kind : UInt8
      EMPTY
      ENTITY
      MAP
    end
    
    property kind : Kind = Kind::EMPTY
    property other_object : Entity | Map | Nil = nil

    def initialize(kind : Kind, other_object : Entity | Map)
      @kind = kind
      @other_object = other_object
    end

    def with_map?
      @kind == Kind::MAP
    end

    def with_entity?
      @kind = Kind::ENTITY
    end
  end
end
