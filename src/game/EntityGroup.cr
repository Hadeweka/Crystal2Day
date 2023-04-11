module Crystal2Day
  class EntityGroup
    @members : Array(Crystal2Day::Entity)
    @refs : Array(Anyolite::RbRef)

    def initialize(capacity : UInt32 = 100)
      @members = Array(Crystal2Day::Entity).new(initial_capacity: capacity)
      @refs = Array(Anyolite::RbRef).new(initial_capacity: capacity)
    end

    def number
      @members.size
    end

    def add_entity
      new_entity = Crystal2Day::Entity.new
      new_ref = Crystal2Day::Interpreter.generate_ref(new_entity)

      @members.push new_entity
      @refs.push new_ref

      new_entity.init

      return @members.size
    end

    def get_entity(index : Number)
      @members[index]
    end

    def delete_entity_at(index : Number)
      @members.delete_at(index).delete
      @refs.delete_at(index)
    end

    def update
      @members.each do |entity|
        entity.update
      end
    end

    def clear
      0.upto(@members.size - 1) do |index|
        delete_entity_at(-1)
      end
    end

    def finalize
      clear
    end
  end
end
