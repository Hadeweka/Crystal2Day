module Crystal2Day
  class Entity
    @state = {} of String => Anyolite::RbRef

    def initialize
    end

    def init
      # TODO: Call init hook
    end

    def get_state(index : String)
      @state[index]
    end

    def set_state(index : String, value)
      @state[index] = Crystal2Day::Interpreter.generate_ref(value)
    end

    @[Anyolite::Specialize]
    def set_state(index : String, value : Anyolite::RbRef)
      @state[index] = value
    end

    def update
      # TODO: Call update hook
    end

    def delete
      # TODO: Call deletion hook
    end
  end
end
