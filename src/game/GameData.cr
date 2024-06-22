module Crystal2Day
  class GameData
    STATE_INITIAL_CAPACITY = 256

    @state = Hash(String, Crystal2Day::Parameter).new(initial_capacity: STATE_INITIAL_CAPACITY)

    def get_state(index : String)
      @state[index]
    end

    def set_state(index : String, value)
      @state[index] = Crystal2Day::Interpreter.generate_ref(value)
    end

    @[Anyolite::Specialize]
    def set_state(index : String, value : Crystal2Day::Parameter)
      @state[index] = value
    end
  end
end
