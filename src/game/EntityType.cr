# A template for entities.
# Each instance is essentially a different entity type.
# You can add default state values, coroutines and procs.

module Crystal2Day
  class EntityType
    DEFAULT_NAME = "<nameless>"

    @default_state = {} of String => Anyolite::RbRef
    @coroutine_templates = {} of String => Crystal2Day::CoroutineTemplate
    @default_procs = {} of String => Proc(Entity, Nil)

    @sprite_templates = Array(Crystal2Day::SpriteTemplate).new
    @boxes = Array(Crystal2Day::CollisionShapeBox).new
    @shapes = Array(Crystal2Day::CollisionShape).new
    @hitshapes = Array(Crystal2Day::CollisionShape).new
    @hurtshapes = Array(Crystal2Day::CollisionShape).new
    
    property name : String = DEFAULT_NAME

    def initialize(name : String = DEFAULT_NAME)
    end

    # TODO: Add hitshapes, hurtshapes, references to Crystal procs etc. to the following routine

    def initialize(pull : JSON::PullParser)
      pull.read_object do |key|
        case key
        when "name" then @name = pull.read_string
        when "default_state"
          pull.read_object do |state_key|
            add_default_state_from_raw_json(name: state_key, raw_json: pull.read_raw)
          end
        when "sprite_templates"
          pull.read_array do
            add_sprite_template_from_raw_json(raw_json: pull.read_raw)
          end
        when "coroutine_templates"
          pull.read_object do |coroutine_key|
            # TODO: Cache loaded files, similar to textures
            pull.read_object do |coroutine_type|
              case coroutine_type
              when "file"
                coroutine = CD::CoroutineTemplate.from_string(File.read(pull.read_string), "entity")
                add_coroutine_template(coroutine_key, coroutine)
              when "code"
                coroutine = CD::CoroutineTemplate.from_string(pull.read_string, "entity")
                add_coroutine_template(coroutine_key, coroutine)
              else
                Crystal2Day.error "Unknown EntityType loading option: #{coroutine_type}"
              end
            end
          end
        when "boxes"
          pull.read_array do
            add_collision_box_from_raw_json(raw_json: pull.read_raw)
          end
        when "shapes"
          pull.read_array do
            add_collision_shape_from_raw_json(raw_json: pull.read_raw)
          end
        when "hitshapes"
          # TODO
        when "hurtshapes"
          # TODO
        when "description"
          # TODO
        end
      end
    end
    
    def add_default_state(name : String, value)
      @default_state[name] = Crystal2Day::Interpreter.generate_ref(value)
    end

    def add_default_state_from_raw_json(name : String, raw_json : String)
      @default_state[name] = Crystal2Day::Interpreter.convert_json_to_ref(raw_json)
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

    # TODO: Decide whether to access sprites by a key or not (same for shapes)

    def add_sprite_template(sprite_template : Crystal2Day::SpriteTemplate)
      @sprite_templates.push sprite_template
    end

    def add_sprite_template_from_raw_json(raw_json : String)
      @sprite_templates.push Crystal2Day::SpriteTemplate.from_json(raw_json)
    end

    def add_collision_box(collision_box : Crystal2Day::CollisionShapeBox)
      @boxes.push collision_box
    end

    def add_collision_box_from_raw_json(raw_json : String)
      @boxes.push Crystal2Day::CollisionShapeBox.from_json(raw_json)
    end

    def add_collision_shape(collision_shape : Crystal2Day::CollisionShape)
      @shapes.push collision_box
    end

    def add_collision_shape_from_raw_json(raw_json : String)
      @shapes.push Crystal2Day::CollisionShape.from_json(raw_json)
    end

    # TODO: Adding routines for hitshapes and hurtshapes

    def transfer_default_state
      @default_state
    end

    def transfer_coroutine_templates
      @coroutine_templates
    end

    def transfer_default_procs
      @default_procs
    end

    def transfer_sprite_templates
      @sprite_templates
    end

    def transfer_boxes
      @boxes
    end

    def transfer_shapes
      @shapes
    end

    def transfer_hitshapes
      @hitshapes
    end

    def transfer_hurtshapes
      @hurtshapes
    end
  end
end
