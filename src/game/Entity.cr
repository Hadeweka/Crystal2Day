module Crystal2Day
  class Entity
    @state = {} of String => Anyolite::RbRef
    @hooks = {} of String => Crystal2Day::Coroutine

    def initialize
    end

    def add_hook_from_template(name : String, template : Crystal2Day::CoroutineTemplate)
      if @hooks[name]?
        Crystal2Day.warning "Hook #{name} was already registered and will be overwritten."
      end
      @hooks[name] = template.generate_hook
    end

    def init(own_ref : Anyolite::RbRef)
      call_hook("init", own_ref)
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

    def update(own_ref : Anyolite::RbRef)
      call_hook("update", own_ref)
    end

    @[Anyolite::Exclude]
    def call_hook(name : String, own_ref : Anyolite::RbRef)
      if @hooks[name]?
        @hooks[name].call(own_ref)
      end
    end

    def delete(own_ref : Anyolite::RbRef)
      call_hook("delete", own_ref)
    end
  end
end
