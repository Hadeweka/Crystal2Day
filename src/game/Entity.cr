# A class for entities with their own state and behavior.
# Generally, you want to use them from an `EntityGroup` with a specific `EntityType`.
# This class is also exposed to the internal mruby interpreter.
# Most properties can also be modified at runtime, so this class is very flexible.

module Crystal2Day
  class Entity
    STATE_INITIAL_CAPACITY = 8
    HOOKS_INITIAL_CAPACITY = 8
    PROCS_INITIAL_CAPACITY = 8
    CHILDREN_INITIAL_CAPACITY = 8

    @state = Hash(String, Anyolite::RbRef).new(initial_capacity: STATE_INITIAL_CAPACITY)
    @hooks = Hash(String, Crystal2Day::Coroutine).new(initial_capacity: HOOKS_INITIAL_CAPACITY)
    @procs = Hash(String, Proc(Entity, Nil)).new(initial_capacity: PROCS_INITIAL_CAPACITY)

    @sprites = Array(Crystal2Day::Sprite).new
    @boxes = Array(Crystal2Day::CollisionShapeBox).new
    @shapes = Array(Crystal2Day::CollisionShape).new
    @hitshapes = Array(Crystal2Day::CollisionShape).new
    @hurtshapes = Array(Crystal2Day::CollisionShape).new

    @children = Array(Entity).new(initial_capacity: CHILDREN_INITIAL_CAPACITY)

    @type_name : String = Crystal2Day::EntityType::DEFAULT_NAME

    getter magic_number : UInt64 = 0u64

    property position : Crystal2Day::Coords = Crystal2Day.xy
    property velocity : Crystal2Day::Coords = Crystal2Day.xy
    property acceleration : Crystal2Day::Coords = Crystal2Day.xy

    @[Anyolite::Specialize]
    def initialize
    end

    def initialize(entity_type : Crystal2Day::EntityType)
      @state.merge! entity_type.transfer_default_state
      @procs.merge! entity_type.transfer_default_procs

      entity_type.transfer_coroutine_templates.each do |name, template|
        add_hook_from_template(name, template)
      end

      entity_type.transfer_sprites.each do |sprite|
        @sprites.push sprite.dup
      end

      entity_type.transfer_boxes.each do |box|
        @boxes.push box.dup
      end

      entity_type.transfer_shapes.each do |shape|
        @shapes.push shape.dup
      end

      entity_type.transfer_hitshapes.each do |hitshape|
        @hitshapes.push hitshape.dup
      end

      entity_type.transfer_hurtshapes.each do |hurtshape|
        @hurtshapes.push hurtshape.dup
      end

      @type_name = entity_type.name
    end

    @[Anyolite::Exclude]
    def add_hook_from_template(name : String, template : Crystal2Day::CoroutineTemplate)
      if @hooks[name]?
        Crystal2Day.warning "Hook #{name} was already registered and will be overwritten."
      end
      @hooks[name] = template.generate_hook
    end

    @[Anyolite::Exclude]
    def add_proc(name : String, &proc : Crystal2Day::Entity -> Nil)
      if @procs[name]?
        Crystal2Day.warning "Proc #{name} was already registered and will be overwritten."
      end
      @procs[name] = proc
    end

    @[Anyolite::Exclude]
    def init(own_ref : Anyolite::RbRef)
      @magic_number = self.object_id
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

    def call_proc(name : String)
      @procs[name].call(self)
    end

    @[Anyolite::Exclude]
    def update(own_ref : Anyolite::RbRef)
      call_hook("update", own_ref)
    end

    @[Anyolite::Exclude]
    def call_hook(name : String, own_ref : Anyolite::RbRef)
      if @hooks[name]?
        @hooks[name].call(own_ref)
      end
    end

    @[Anyolite::Exclude]
    def delete(own_ref : Anyolite::RbRef)
      call_hook("delete", own_ref)
    end

    def draw
      # TODO
    end
  end
end
