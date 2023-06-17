# An abstract scene class.
# Just derive your own scene class from it and overload the empty methods.

module Crystal2Day
  class Scene
    ENTITY_GROUP_INITIAL_CAPACITY = 8
    UPDATE_GROUP_INITIAL_CAPACITY = 8
    PHYSICS_GROUP_INITIAL_CAPACITY = 8
    EVENT_GROUP_INITIAL_CAPACITY = 8
    DRAW_GROUP_INITIAL_CAPACITY = 8
    MAPS_INITIAL_CAPACITY = 8

    property use_own_draw_implementation : Bool = false

    getter entity_groups : Hash(String, EntityGroup) = Hash(String, EntityGroup).new(initial_capacity: ENTITY_GROUP_INITIAL_CAPACITY)
    getter update_groups : Array(EntityGroup) = Array(EntityGroup).new(initial_capacity: UPDATE_GROUP_INITIAL_CAPACITY)
    getter physics_groups : Array(EntityGroup) = Array(EntityGroup).new(initial_capacity: PHYSICS_GROUP_INITIAL_CAPACITY)
    getter event_groups : Array(EntityGroup) = Array(EntityGroup).new(initial_capacity: EVENT_GROUP_INITIAL_CAPACITY)
    getter draw_groups : Array(EntityGroup) = Array(EntityGroup).new(initial_capacity: DRAW_GROUP_INITIAL_CAPACITY)

    getter maps : Hash(String, Map) = Hash(String, Map).new(initial_capacity: MAPS_INITIAL_CAPACITY)

    def handle_event(event)
    end

    def init
    end

    def exit
    end

    def update
    end

    def post_update
    end

    def draw
    end

    def initialize
    end

    def process_events
      Crystal2Day.poll_events do |event|
        handle_event(event.not_nil!)

        @event_groups.each {|member| member.handle_event(event.not_nil!)}
      end
    end

    def main_update
      update

      @update_groups.each {|member| member.update}

      update_physics

      @update_groups.each {|member| member.post_update}

      post_update
    end

    def update_physics
      # TODO: Add adaptive time steps
      Crystal2Day.number_of_physics_steps.times do |i|
        physics_step
      end

      @physics_groups.each {|member| member.reset_acceleration}
    end

    def physics_step
      @physics_groups.each {|member| member.update_physics}
    end

    def main_draw
      if @use_own_draw_implementation
        call_inner_draw_block
      elsif win = Crystal2Day.current_window_if_any
        win.clear
        call_inner_draw_block
        win.render_and_display
      end
    end

    def exit_routine
      exit
      Crystal2Day.windows.each do |window|
        window.unpin_all
      end
      @update_groups.clear
      @physics_groups.clear
      @event_groups.clear
      @draw_groups.clear
      @entity_groups.clear
    end

    def call_inner_draw_block
      draw
      @draw_groups.each {|member| member.draw}
    end

    def add_entity_group(name, auto_update : Bool = false, auto_physics : Bool = false, auto_events : Bool = false, auto_draw : Bool = false, capacity : UInt32 = 0)
      if @entity_groups[name]?
        Crystal2Day.warning "Already existing entity group with name '#{name}' will be overwritten"
      end
      
      new_entity_group = capacity == 0 ? EntityGroup.new : EntityGroup.new(capacity: capacity)
      @entity_groups[name] = new_entity_group

      @update_groups.push new_entity_group if auto_update
      @physics_groups.push new_entity_group if auto_physics
      @event_groups.push new_entity_group if auto_events
      @draw_groups.push new_entity_group if auto_draw

      return new_entity_group
    end

    def add_entity(group : String, type : String | EntityType, position : Crystal2Day::Coords = Crystal2Day.xy)
      @entity_groups[group].add_entity(type, position)
    end

    def add_map(name : String, tileset : Tileset?)
      if @maps[name]?
        Crystal2Day.warning "Already existing map with name '#{name}' will be overwritten"
      end

      new_map = CD::Map.new
      @maps[name] = new_map
      new_map.tileset = tileset.not_nil! if tileset

      return new_map
    end
  end
end
