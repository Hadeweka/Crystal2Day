# A class for entities with their own state and behavior.
# Generally, you want to use them from an `EntityGroup` with a specific `EntityType`.
# This class is also exposed to the internal mruby interpreter.
# Most properties can also be modified at runtime, so this class is very flexible.

module Crystal2Day
  class Entity
    STATE_INITIAL_CAPACITY = 8
    HOOKS_INITIAL_CAPACITY = 16
    CHILDREN_INITIAL_CAPACITY = 8
    HOOK_STACK_INITIAL_CAPACITY = 8
    COLLISION_STACK_ENTITIES_INITIAL_CAPACITY = 8
    COLLISION_STACK_TILES_INITIAL_CAPACITY = 32

    INITIAL_PARAM_NAME = "initial_param"

    # If positive, this will discretize every motion into steps with the given size in each direction
    DEFAULT_OPTION_MOVEMENT_DISCRETIZATION = -1

    # TODO: This does currently nothing
    property z : UInt8 = 0

    @state = Hash(String, Crystal2Day::Parameter).new(initial_capacity: STATE_INITIAL_CAPACITY)

    getter current_hook : String = ""
    @hooks = Hash(String, Hook).new(initial_capacity: HOOKS_INITIAL_CAPACITY)
    @hook_stack = Deque(String).new(initial_capacity: HOOK_STACK_INITIAL_CAPACITY)
    property next_hook : String? = nil

    @options = Hash(String, Int64).new

    getter sprites = Array(Crystal2Day::Sprite).new
    getter bounding_boxes = Array(Crystal2Day::CollisionShapeBox).new
    getter map_boxes = Array(Crystal2Day::CollisionShapeBox).new
    getter shapes = Array(Crystal2Day::CollisionShape).new
    getter hitshapes = Array(Crystal2Day::CollisionShape).new
    getter hurtshapes = Array(Crystal2Day::CollisionShape).new

    @children = Array(Entity).new(initial_capacity: CHILDREN_INITIAL_CAPACITY)

    getter type_name : String = Crystal2Day::EntityType::DEFAULT_NAME

    @renderer : Crystal2Day::Renderer

    getter current_time_step : Float32 = 0.0

    @collision_stack_entities = Deque(CollisionReference).new(initial_capacity: COLLISION_STACK_ENTITIES_INITIAL_CAPACITY)
    @collision_stack_tiles = Deque(CollisionReference).new(initial_capacity: COLLISION_STACK_TILES_INITIAL_CAPACITY)

    getter magic_number : UInt64 = 0u64

    property position : Crystal2Day::Coords = Crystal2Day.xy
    property velocity : Crystal2Day::Coords = Crystal2Day.xy
    property acceleration : Crystal2Day::Coords = Crystal2Day.xy

    property terminal_speed : Float32 = 100.0 # TODO: Implement this as an option

    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
    end

    def initialize(entity_type : Crystal2Day::EntityType, @renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      @state.merge! entity_type.transfer_default_state
      @options.merge! entity_type.transfer_options

      entity_type.transfer_coroutine_templates.each do |name, template|
        add_hook_from_template(name, template)
      end

      entity_type.transfer_sprite_templates.each do |sprite_template|
        @sprites.push Crystal2Day::Sprite.new(sprite_template)
      end

      entity_type.transfer_bounding_boxes.each do |box|
        @bounding_boxes.push box.dup
      end

      entity_type.transfer_map_boxes.each do |box|
        @map_boxes.push box.dup
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

    # TODO: Maybe allow args in some way?
    def call_proc(name : String)
      Crystal2Day.database.call_entity_proc(name, self)
    end

    def add_hook_from_template(name : String, template : Crystal2Day::CoroutineTemplate)
      if @hooks[name]?
        Crystal2Day.warning "Hook #{name} was already registered and will be overwritten."
      end
      @hooks[name] = template.generate_hook
    end

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def init(own_ref : Anyolite::RbRef, initial_param : Crystal2Day::ParamType = nil)
        @magic_number = self.object_id
        set_state(INITIAL_PARAM_NAME, initial_param)
        call_hook("init", own_ref)
      end
    {% else %}
      def init(initial_param : Crystal2Day::ParamType = nil)
        @magic_number = self.object_id
        set_state(INITIAL_PARAM_NAME, initial_param)
        call_hook("init")
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def update(own_ref : Anyolite::RbRef)
        call_hook("update", own_ref)
      end
    {% else %}
      def update
        call_hook("update")
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def post_update(own_ref : Anyolite::RbRef)
        update_sprites
        call_hook("post_update", own_ref)
      end
    {% else %}
      def post_update
        update_sprites
        call_hook("post_update")
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def handle_event(own_ref : Anyolite::RbRef)
        call_hook("handle_event", own_ref)
      end
    {% else %}
      def handle_event
        call_hook("handle_event")
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def update_physics(own_ref : Anyolite::RbRef, time_step : Float32)
        @current_time_step = time_step
        call_hook_or("custom_physics", own_ref) {update_physics_internal}
      end
    {% else %}
      def update_physics(time_step : Float32)
        @current_time_step = time_step
        call_hook_or("custom_physics") {update_physics_internal}
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def delete(own_ref : Anyolite::RbRef)
        call_hook("delete", own_ref)
      end
    {% else %}
      def delete
        call_hook("delete")
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def call_collision_hooks(own_ref : Anyolite::RbRef)
        call_hook("tile_collisions", own_ref)
        @collision_stack_tiles.clear

        call_hook("entity_collisions", own_ref)
        @collision_stack_entities.clear
      end
    {% else %}
      def call_collision_hooks
        call_hook("tile_collisions")
        @collision_stack_tiles.clear

        call_hook("entity_collisions")
        @collision_stack_entities.clear
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def call_existing_hook(name : String, own_ref : Anyolite::RbRef)
        @current_hook = name
        is_ruby = @hooks[name].is_currently_ruby?
        @hooks[name].call(self, own_ref)
        if next_hook_name = @next_hook
          @hook_stack.push name if is_ruby
          @next_hook = nil
          call_hook(next_hook_name, own_ref)
          call_hook(@hook_stack.pop, own_ref) if is_ruby
        end
        @current_hook = ""
      end
    {% else %}
      def call_existing_hook(name : String)
        @current_hook = name
        @hooks[name].call(self)
        if next_hook_name = @next_hook
          @next_hook = nil
          call_hook(next_hook_name)
        end
        @current_hook = ""
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def call_hook(name : String, own_ref : Anyolite::RbRef)
        if @hooks[name]?
          call_existing_hook(name, own_ref)
        end
      end
    {% else %}
      def call_hook(name : String)
        if @hooks[name]?
          call_existing_hook(name)
        end
      end
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def call_hook_or(name : String, own_ref : Anyolite::RbRef)
        if @hooks[name]?
          call_existing_hook(name, own_ref)
        else
          yield
        end
      end
    {% else %}
      def call_hook_or(name : String)
        if @hooks[name]?
          call_existing_hook(name)
        else
          yield
        end
      end
    {% end %}

    def get_state(index : String)
      @state[index]
    end

    def set_state(index : String, value)
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        @state[index] = Crystal2Day::Interpreter.generate_ref(value)
      {% else %}
        @state[index] = Crystal2Day::Parameter.new(value)
      {% end %}
    end

    def set_state(index : String, value : Crystal2Day::Parameter)
      @state[index] = value
    end

    def get_option(name : String, default : Int64)
      if @options[name]?
        @options[name]
      else
        default
      end
    end

    def update_sprites
      @sprites.each do |sprite|
        sprite.update
      end
    end

    def acceleration_step
      @velocity += @acceleration * Crystal2Day.physics_time_step
      @velocity.x = @terminal_speed if @velocity.x > @terminal_speed
      @velocity.x = -@terminal_speed if @velocity.x < -@terminal_speed
      @velocity.y = @terminal_speed if @velocity.y > @terminal_speed
      @velocity.y = -@terminal_speed if @velocity.y < -@terminal_speed
    end

    def update_physics_internal
      # TODO: Maybe add other integration schemes like Leapfrog or Runge-Kutta
      @position += @velocity * @current_time_step
    end

    def reset_acceleration
      @acceleration = Crystal2Day.xy
    end

    def accelerate(value : Crystal2Day::Coords)
      @acceleration += value
    end

    def change_hook_page_to(name : String)
      @hooks[@current_hook].change_page(name)
    end

    def get_sprite(index : UInt32)
      @sprites[index]
    end

    def activate_sprite(index : UInt32)
      @sprites[index].active = true
    end

    def deactivate_sprite(index : UInt32)
      @sprites[index].active = false
    end

    def activate_shape(index : UInt32)
      @shapes[index].active = true
    end

    def deactivate_shape(index : UInt32)
      @shapes[index].active = false
    end

    def activate_bounding_box(index : UInt32)
      @bounding_boxes[index].active = true
    end

    def deactivate_bounding_box(index : UInt32)
      @bounding_boxes[index].active = false
    end

    def activate_map_box(index : UInt32)
      @map_boxes[index].active = true
    end

    def deactivate_map_box(index : UInt32)
      @map_boxes[index].active = false
    end

    def is_exactly_type?(other_type_name : String)
      @type_name == other_type_name
    end

    def is_type?(other_type_name : String)
      Crystal2Day.database.get_entity_type(@type_name).based_on?(other_type_name)
    end

    # TODO: Integrate parent-child offset
    # TODO: Is there any way to enable pinning this?
    def draw(offset : Coords = Crystal2Day.xy)
      @sprites.each do |sprite|
        sprite.draw(@position + offset)
      end
    end

    def each_tile_collision
      @collision_stack_tiles.each do |collision_reference|
        yield collision_reference
      end
    end

    def each_entity_collision
      @collision_stack_entities.each do |collision_reference|
        yield collision_reference
      end
    end

    def add_entity_collision_reference(other_entity : Entity)
      @collision_stack_entities.push CollisionReference.new(CollisionReference::Kind::ENTITY, other_entity, other_entity.position)
    end

    def add_tile_collision_reference(tile : Tile, position : Coords, tileset : Tileset)
      @collision_stack_tiles.push CollisionReference.new(CollisionReference::Kind::TILE, tile, position, tileset)
    end

    def check_for_collision_with(map : Map)
      map_width = map.content.width
      map_height = map.content.height
      tile_width = map.tileset.tile_width
      tile_height = map.tileset.tile_height

      # TODO: Why 100 here?

      minimum_x = (map_width + 100) * tile_width
      minimum_y = (map_height + 100) * tile_height
      maximum_x = -100.0 * tile_width
      maximum_y = -100.0 * tile_height

      @bounding_boxes.each do |box|
        box_corner_low = @position + box.position
        box_corner_high = box_corner_low + box.size.scale(box.scale)
        box_minimum_x = box_corner_low.x
        box_minimum_y = box_corner_low.y
        box_maximum_x = box_corner_high.x
        box_maximum_y = box_corner_high.y

        minimum_x = box_minimum_x if box_minimum_x < minimum_x
        minimum_y = box_minimum_y if box_minimum_y < minimum_y
        maximum_x = box_maximum_x if box_maximum_x > maximum_x
        maximum_y = box_maximum_y if box_maximum_y > maximum_y
      end

      # Add one pixel for tolerance

      minimum_map_x = ((minimum_x - 1) / tile_width).floor.to_i
      minimum_map_y = ((minimum_y - 1) / tile_height).floor.to_i
      maximum_map_x = ((maximum_x + 1) / tile_width).floor.to_i
      maximum_map_y = ((maximum_y + 1) / tile_height).floor.to_i

      # TODO: Add map shifts

      # TODO: Better map collision system

      minimum_map_x.upto(maximum_map_x) do |x|
        next if x < 0 || x >= map.content.width
        minimum_map_y.upto(maximum_map_y) do |y|
          next if y < 0 || y >= map.content.height
          tile_id = map.content.get_tile(x, y)
          tile = map.tileset.get_tile(tile_id)
          tile_shape = CollisionShapeBox.new(size: Crystal2Day.xy(tile_width, tile_height))
          tile_position = Crystal2Day.xy(x * tile_width, y * tile_height)
          @map_boxes.each do |shape_own|
            if Crystal2Day::Collider.test(shape_own, aligned_position, tile_shape, tile_position)
              add_tile_collision_reference(tile, tile_position, map.tileset)
            end
          end
        end
      end
    end

    def aligned_position
      if Crystal2Day.grid_alignment == 0
        @position
      else
        Crystal2Day.xy((@position.x / Crystal2Day.grid_alignment).round * Crystal2Day.grid_alignment, (@position.y / Crystal2Day.grid_alignment).round * Crystal2Day.grid_alignment)
      end
    end

    def check_for_collision_with(other : Entity)
      # Avoid collisions with yourself
      # TODO: Maybe add an option to turn this off
      return false if self == other

      # TODO: Maybe make the bounding box check optional, e.g. for maps
      
      # Step 1: Compare boxes
      collision_detected = false
      @bounding_boxes.each do |box_own|
        other.bounding_boxes.each do |box_other|
          if Crystal2Day::Collider.test(box_own, @position, box_other, other.position)
            collision_detected = true
            break
          end
        end
      end
      
      return false unless collision_detected
      
      # Step 2: Compare actual shapes
      collision_detected = false
      @shapes.each do |shape_own|
        other.shapes.each do |shape_other|
          if Crystal2Day::Collider.test(shape_own, @position, shape_other, other.position)
            collision_detected = true
            add_entity_collision_reference(other)
            other.add_entity_collision_reference(self)
            break
          end
        end
      end

      # TODO: Test all shapes if hitshapes are becoming relevant
      return collision_detected
    end
  end
end
