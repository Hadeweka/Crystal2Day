# This class serves as a container for multiple entities.
# Use these to group similar entities together, for easier management.
# Using this class also takes care of any mruby memory management.

module Crystal2Day
  class EntityGroup
    BASE_INITIAL_CAPACITY = 128u32

    @members : Array(Crystal2Day::Entity)
    @refs : Array(Anyolite::RbRef)
    @renderer : Crystal2Day::Renderer

    def initialize(capacity : UInt32 = BASE_INITIAL_CAPACITY, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      @members = Array(Crystal2Day::Entity).new(initial_capacity: capacity)
      @refs = Array(Anyolite::RbRef).new(initial_capacity: capacity)
    end

    def number
      @members.size
    end

    def add_entity(entity_type : Crystal2Day::EntityType, position : Crystal2Day::Coords = Crystal2Day.xy)
      new_entity = Crystal2Day::Entity.new(entity_type, renderer: @renderer)
      new_entity.position = position
      register_new_entity(new_entity)
    end

    def add_entity(position : Crystal2Day::Coords = Crystal2Day.xy)
      new_entity = Crystal2Day::Entity.new(renderer: @renderer)
      new_entity.position = position
      register_new_entity(new_entity)
    end

    def register_new_entity(entity : Crystal2Day::Entity)
      new_ref = Crystal2Day::Interpreter.generate_ref(entity)
      
      @members.push entity
      @refs.push new_ref

      entity.init(new_ref)

      return @members.size
    end

    def get_entity(index : Number)
      @members[index]
    end

    def delete_entity_at(index : Number)
      @members.delete_at(index).delete(@refs.delete_at(index))
    end

    def update
      0.upto(@members.size - 1) do |index|
        @members[index].update(@refs[index])
      end
    end

    def clear
      0.upto(@members.size - 1) do |index|
        delete_entity_at(-1)
      end
    end

    def draw(offset : Coords = Crystal2Day.xy)
      @members.each do |entity|
        entity.draw(offset)
      end
    end

    def finalize
      clear
    end
  end
end
