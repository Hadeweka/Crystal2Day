module Crystal2Day
  class Database
    ENTITY_TYPES_INITIAL_CAPACITY = 256

    @entity_types = Hash(String, Crystal2Day::EntityType).new(initial_capacity: ENTITY_TYPES_INITIAL_CAPACITY)

    def load_entity_type_from_file(filename)
      entity_type = Crystal2Day::EntityType.from_json_file(filename)
      if @entity_types[entity_type.name]?
        Crystal2Day.debug_log "Updated entity type: #{entity_type.name} from #{filename}."
      end
      @entity_types[entity_type.name] = entity_type
    end

    def get_entity_type(name)
      @entity_types[name]
    end
  end
end
