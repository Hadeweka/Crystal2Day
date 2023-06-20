# This class serves as a container for multiple entities.
# Use these to group similar entities together, for easier management.
# Using this class also takes care of any mruby memory management.

module Crystal2Day
  class EntityGroup
    BASE_INITIAL_CAPACITY = 128u32

    getter members : Array(Crystal2Day::Entity)
    @refs : Array(Anyolite::RbRef)
    @renderer : Crystal2Day::Renderer

    def initialize(capacity : UInt32 = BASE_INITIAL_CAPACITY, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      @members = Array(Crystal2Day::Entity).new(initial_capacity: capacity)
      @refs = Array(Anyolite::RbRef).new(initial_capacity: capacity)
    end

    def number
      @members.size
    end

    def add_entity(entity_type_name : String, position : Crystal2Day::Coords = Crystal2Day.xy)
      entity_type = CD.database.get_entity_type(entity_type_name)
      new_entity = Crystal2Day::Entity.new(entity_type, renderer: @renderer)
      new_entity.position = position
      register_new_entity(new_entity)
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

    def handle_event(event : Crystal2Day::Event)
      Crystal2Day.last_event = event
      0.upto(@members.size - 1) do |index|
        @members[index].handle_event(@refs[index])
      end
      Crystal2Day.last_event = nil
    end

    def update_physics
      0.upto(@members.size - 1) do |index|
        @members[index].update_physics(@refs[index])
      end
    end

    def reset_acceleration
      @members.each do |member|
        member.reset_acceleration
      end
    end

    def post_update
      0.upto(@members.size - 1) do |index|
        @members[index].post_update(@refs[index])
      end
    end

    def check_for_collision_with(other : EntityGroup | Map)
      if other.is_a?(EntityGroup)
        if other == self
          0.upto(@members.size - 1) do |index_1|
            index_1.upto(@members.size - 1) do |index_2|
              entity_1 = @members[index_1]
              entity_2 = @members[index_2]

              entity_1.check_for_collision_with(entity_2)
            end
          end
        else
          @members.each do |entity_1|
            other.as(EntityGroup).members.each do |entity_2|
              entity_1.check_for_collision_with(entity_2)
            end
          end
        end
      else
        @members.each do |entity|
          entity.check_for_collision_with(other.as(Map))
        end
      end
    end

    def call_collision_hooks
      0.upto(@members.size - 1) do |index|
        @members[index].call_collision_hooks(@refs[index])
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
