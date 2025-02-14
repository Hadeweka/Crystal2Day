# A thin layer around the SDL event classes, to allow for easier handling.

module Crystal2Day
  {% for potential_event_class in LibSDL.constants %}
    {% parsed_name = parse_type(potential_event_class.stringify).stringify %}
    {% if parsed_name != "Event" && parsed_name.ends_with?("Event") %}
      alias {{parsed_name.id}} = LibSDL::{{parsed_name.id}}
    {% end %}
  {% end %}

  struct WindowEvent
    {% for window_event_type in LibSDL::WindowEvent.constants %}
      {{window_event_type.stringify.gsub(/WINDOWEVENT_/, "").id}} = {{LibSDL::WindowEvent.constant(window_event_type)}}
    {% end %}
  end

  struct KeyboardEvent
    def key
      self.keysym.sym.to_i
    end

    def key_name
      String.new(LibSDL.get_key_name(self.keysym.sym))
    end
  end

  class Event
    @data : LibSDL::Event

    {% for event_type in LibSDL::EventType.constants %}
      {{event_type.stringify.gsub(/EVENT/, "").id}} = {{LibSDL::EventType.constant(event_type)}}
    {% end %}
    
    def data
      @data
    end

    def initialize(other_event : Crystal2Day::Event)
      @data = other_event.data
    end

    def initialize(raw_event : LibSDL::Event)
      @data = raw_event
    end

    def type
      @data.type
    end

    macro obtain_event_type_names
      {
        {% for event_type in LibSDL::EventType.constants %}
          {{LibSDL::EventType.constant(event_type)}} => {{event_type.stringify}},
        {% end %}
      }
    end

    TYPE_NAMES = obtain_event_type_names

    macro generate_event_wrapper(name, union_part, constants)
      def as_{{name.id}}_event
        if {{constants.map{|const| "LibSDL::EventType::#{const}.to_i".id}}}.includes?(type) 
          @data.{{union_part.id}}
        else
          Crystal2Day.error "Could not cast event with ID #{TYPE_NAMES[type]} to {{name.id}} event"
        end
      end

      def is_{{name.id}}_event?
        if {{constants.map{|const| "LibSDL::EventType::#{const}.to_i".id}}}.includes?(type)
          return true
        else
          return false
        end
      end
    end

    generate_event_wrapper(:display, :display, {
      DISPLAY_ORIENTATION,
      DISPLAY_ADDED,
      DISPLAY_REMOVED,
      DISPLAY_MOVED,
      DISPLAY_DESKTOP_MODE_CHANGED,
      DISPLAY_CURRENT_MODE_CHANGED,
      DISPLAY_CONTENT_SCALE_CHANGED
    })

    generate_event_wrapper(:window, :window, {
      WINDOW_SHOWN,
      WINDOW_HIDDEN,
      WINDOW_EXPOSED,
      WINDOW_MOVED,
      WINDOW_RESIZED,
      WINDOW_PIXEL_SIZE_CHANGED,
      WINDOW_METAL_VIEW_RESIZED,
      WINDOW_MINIMIZED,
      WINDOW_MAXIMIZED,
      WINDOW_RESTORED,
      WINDOW_MOUSE_ENTER,
      WINDOW_MOUSE_LEAVE,
      WINDOW_FOCUS_GAINED,
      WINDOW_FOCUS_LOST,
      WINDOW_CLOSE_REQUESTED,
      WINDOW_HIT_TEST,
      WINDOW_ICCPROF_CHANGED,
      WINDOW_DISPLAY_CHANGED,
      WINDOW_DISPLAY_SCALE_CHANGED,
      WINDOW_SAFE_AREA_CHANGED,
      WINDOW_OCCLUDED,
      WINDOW_ENTER_FULLSCREEN,
      WINDOW_LEAVE_FULLSCREEN,
      WINDOW_DESTROYED,
      WINDOW_HDR_STATE_CHANGED
    })

    generate_event_wrapper(:keyboard_device, :kdevice, {KEYBOARD_ADDED, KEYBOARD_REMOVED})
    generate_event_wrapper(:key, :key, {KEY_DOWN, KEY_UP})
    generate_event_wrapper(:text_editing_event, :edit, {TEXT_EDITING})
    generate_event_wrapper(:text_editing_candidates, :edit_candidates, {TEXT_EDITING_CANDIDATES})
    generate_event_wrapper(:text_input, :text, {TEXT_INPUT})
    generate_event_wrapper(:mouse_device, :mdevice, {MOUSE_ADDED, MOUSE_REMOVED})
    generate_event_wrapper(:mouse_motion, :motion, {MOUSE_MOTION})
    generate_event_wrapper(:mouse_button, :button, {MOUSE_BUTTON_DOWN, MOUSE_BUTTON_UP})
    generate_event_wrapper(:mouse_wheel, :wheel, {MOUSE_WHEEL})
    generate_event_wrapper(:joy_device, :jdevice, {JOYSTICK_ADDED, JOYSTICK_REMOVED, JOYSTICK_UPDATE_COMPLETE})
    generate_event_wrapper(:joy_axis, :jaxis, {JOYSTICK_AXIS_MOTION})
    generate_event_wrapper(:joy_ball, :jball, {JOYSTICK_BALL_MOTION})
    generate_event_wrapper(:joy_hat, :jhat, {JOYSTICK_HAT_MOTION})
    generate_event_wrapper(:joy_button, :jbutton, {JOYSTICK_BUTTON_DOWN, JOYSTICK_BUTTON_UP})
    generate_event_wrapper(:joy_battery, :jbattery, {JOYSTICK_BATTERY_UPDATED})
    generate_event_wrapper(:gamepad_device, :gdevice, {GAMEPAD_ADDED, GAMEPAD_REMOVED, GAMEPAD_REMAPPED, GAMEPAD_UPDATE_COMPLETE, GAMEPAD_STEAM_HANDLE_UPDATED})
    generate_event_wrapper(:gamepad_axis, :gaxis, {GAMEPAD_AXIS_MOTION})
    generate_event_wrapper(:gamepad_button, :gbutton, {GAMEPAD_BUTTON_DOWN, GAMEPAD_BUTTON_UP})
    generate_event_wrapper(:gamepad_touchpad, :gtouchpad, {GAMEPAD_TOUCHPAD_DOWN, GAMEPAD_TOUCHPAD_MOTION, GAMEPAD_TOUCHPAD_UP})
    generate_event_wrapper(:gamepad_sensor, :gsensor, {GAMEPAD_SENSOR_UPDATE})
    generate_event_wrapper(:audio_device, :adevice, {AUDIO_DEVICE_ADDED, AUDIO_DEVICE_REMOVED, AUDIO_DEVICE_FORMAT_CHANGED})
    generate_event_wrapper(:camera_device, :cdevice, {CAMERA_DEVICE_ADDED, CAMERA_DEVICE_REMOVED, CAMERA_DEVICE_APPROVED, CAMERA_DEVICE_DENIED})
    generate_event_wrapper(:sensor, :sensor, {SENSOR_UPDATE})
    generate_event_wrapper(:quit, :quit, {QUIT})
    generate_event_wrapper(:user, :user, {USER})  # TODO: This should technically allow all events until LAST, too - fix this at some point
    generate_event_wrapper(:touch_finger, :tfinger, {FINGER_DOWN, FINGER_UP, FINGER_MOTION, FINGER_CANCELED})
    generate_event_wrapper(:pen_proximity, :pproximity, {PEN_PROXIMITY_IN, PEN_PROXIMITY_OUT})
    generate_event_wrapper(:pen_touch, :ptouch, {PEN_DOWN, PEN_UP})
    generate_event_wrapper(:pen_motion, :pmotion, {PEN_MOTION})
    generate_event_wrapper(:pen_button, :pbutton, {PEN_BUTTON_DOWN, PEN_BUTTON_UP})
    generate_event_wrapper(:pen_axis, :paxis, {PEN_AXIS})
    generate_event_wrapper(:render, :render, {RENDER_TARGETS_RESET, RENDER_DEVICE_RESET, RENDER_DEVICE_LOST})
    generate_event_wrapper(:drop, :drop, {DROP_BEGIN, DROP_FILE, DROP_TEXT, DROP_COMPLETE, DROP_POSITION})
    generate_event_wrapper(:clipboard, :clipboard, {CLIPBOARD_UPDATE})
  end
end
