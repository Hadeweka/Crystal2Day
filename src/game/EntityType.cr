# A template for entities.
# Each instance is essentially a different entity type.
# You can add default state values, coroutines and procs.

module Crystal2Day
  class EntityType
    DEFAULT_NAME = "<nameless>"

    @default_state = {} of String => Anyolite::RbRef
    @coroutine_templates = {} of String => Crystal2Day::CoroutineTemplate
    @default_procs = {} of String => Proc(Entity, Nil)

    @sprites = Array(Crystal2Day::Sprite).new
    @boxes = Array(Crystal2Day::CollisionShapeBox).new
    @shapes = Array(Crystal2Day::CollisionShape).new
    @hitshapes = Array(Crystal2Day::CollisionShape).new
    @hurtshapes = Array(Crystal2Day::CollisionShape).new
    
    property name : String = DEFAULT_NAME

    def initialize(name : String = DEFAULT_NAME)
    end

    def add_default_state(name : String, value)
      @default_state[name] = Crystal2Day::Interpreter.generate_ref(value)
    end

    def add_coroutine_template(name : String, template : Crystal2Day::CoroutineTemplate)
      @coroutine_templates[name] = template
    end

    def add_default_proc(name : String, proc : Proc(Entity, Nil))
      @default_procs[name] = proc
    end

    def add_default_proc(name : String, &proc : Crystal2Day::Entity -> Nil)
      @default_procs[name] = proc
    end

    def transfer_default_state
      @default_state
    end

    def transfer_coroutine_templates
      @coroutine_templates
    end

    def transfer_default_procs
      @default_procs
    end
  end
end
