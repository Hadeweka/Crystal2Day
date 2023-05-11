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

    # If positive, this will discretize every motion into steps with the given size in each direction
    DEFAULT_OPTION_MOVEMENT_DISCRETIZATION = -1

    property z : UInt8 = 0

    @state = Hash(String, Anyolite::RbRef).new(initial_capacity: STATE_INITIAL_CAPACITY)
    @hooks = Hash(String, Crystal2Day::Coroutine).new(initial_capacity: HOOKS_INITIAL_CAPACITY)
    @procs = Hash(String, Proc(Entity, Nil)).new(initial_capacity: PROCS_INITIAL_CAPACITY)

    @options = Hash(String, Int64).new

    @sprites = Array(Crystal2Day::Sprite).new
    @boxes = Array(Crystal2Day::CollisionShapeBox).new
    @shapes = Array(Crystal2Day::CollisionShape).new
    @hitshapes = Array(Crystal2Day::CollisionShape).new
    @hurtshapes = Array(Crystal2Day::CollisionShape).new

    @children = Array(Entity).new(initial_capacity: CHILDREN_INITIAL_CAPACITY)

    @type_name : String = Crystal2Day::EntityType::DEFAULT_NAME

    @renderer : Crystal2Day::Renderer

    getter magic_number : UInt64 = 0u64

    property position : Crystal2Day::Coords = Crystal2Day.xy
    property velocity : Crystal2Day::Coords = Crystal2Day.xy
    property acceleration : Crystal2Day::Coords = Crystal2Day.xy

    @[Anyolite::Specialize(nil)]
    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
    end

    def initialize(entity_type : Crystal2Day::EntityType, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      @state.merge! entity_type.transfer_default_state
      @procs.merge! entity_type.transfer_default_procs
      @options.merge! entity_type.transfer_options

      entity_type.transfer_coroutine_templates.each do |name, template|
        add_hook_from_template(name, template)
      end

      entity_type.transfer_sprite_templates.each do |sprite_template|
        @sprites.push Crystal2Day::Sprite.new(sprite_template)
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

    def get_option(name : String, default : Int64)
      if @options[name]?
        @options[name]
      else
        default
      end
    end

    def call_proc(name : String)
      @procs[name].call(self)
    end

    @[Anyolite::Exclude]
    def update(own_ref : Anyolite::RbRef)
      call_hook("update", own_ref)
      call_hook_or("custom_physics", own_ref) {update_physics}
      @sprites.each do |sprite|
        sprite.update
      end
      call_hook("post_update", own_ref)
    end

    @[Anyolite::Exclude]
    def handle_event(own_ref : Anyolite::RbRef)
      call_hook("handle_event", own_ref)
    end

    @[Anyolite::Exclude]
    def update_physics
      @velocity += @acceleration * Crystal2Day.physics_time_step

      movement_discretization = get_option("movement_discretization", DEFAULT_OPTION_MOVEMENT_DISCRETIZATION)
      
      if movement_discretization > 0
        # TODO: Maybe this can be done a bit more smoothly (e.g. vx = 31 with discretization 5 into actual discretization 31/7 ~ 4.42 instead?)
        dx = @velocity.x * Crystal2Day.physics_time_step
        dy = @velocity.y * Crystal2Day.physics_time_step

        while dx.abs + dy.abs > 0
          if dx.abs >= movement_discretization
            actual_difference = dx.sign * movement_discretization
            @position.x += actual_difference
            dx -= actual_difference
          elsif dx.abs > 0
            @position.x += dx
            dx = 0
          end
          if dy.abs >= movement_discretization
            actual_difference = dy.sign * movement_discretization
            @position.y += actual_difference
            dy -= actual_difference
          elsif dy.abs > 0
            @position.y += dy
            dy = 0
          end
          # TODO: Check here for collisions
        end
      else
        @position += @velocity * Crystal2Day.physics_time_step
      end
      @acceleration = Crystal2Day.xy
    end

    def accelerate(value : Crystal2Day::Coords)
      @acceleration += value
    end

    @[Anyolite::Exclude]
    def call_hook(name : String, own_ref : Anyolite::RbRef)
      if @hooks[name]?
        @hooks[name].call(own_ref)
      end
    end

    @[Anyolite::Exclude]
    def call_hook_or(name : String, own_ref : Anyolite::RbRef)
      if @hooks[name]?
        @hooks[name].call(own_ref)
      else
        yield
      end
    end

    @[Anyolite::Exclude]
    def delete(own_ref : Anyolite::RbRef)
      call_hook("delete", own_ref)
    end

    def get_sprite(index : UInt32)
      @sprites[index]
    end

    # TODO: Integrate parent-child offset
    # TODO: Is there any way to enable pinning this?
    def draw(offset : Coords = Crystal2Day.xy)
      @sprites.each do |sprite|
        sprite.draw(@position + offset)
      end
    end
  end
end
