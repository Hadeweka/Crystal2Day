module Crystal2Day
  {% for potential_event_class in LibSDL.constants %}
    {% parsed_name = parse_type(potential_event_class.stringify).stringify %}
    {% if parsed_name != "Event" && parsed_name.ends_with?("Event") %}
      alias {{parsed_name.id}} = LibSDL::{{parsed_name.id}}
    {% end %}
  {% end %}

  struct WindowEvent
    {% for window_event_type in LibSDL::WindowEventID.constants %}
      {{window_event_type.stringify.gsub(/WINDOWEVENT_/, "").id}} = {{LibSDL::WindowEventID.constant(window_event_type)}}
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
    end

    generate_event_wrapper(:display, :display, {DISPLAYEVENT})
    generate_event_wrapper(:window, :window, {WINDOWEVENT})
    generate_event_wrapper(:key, :key, {KEYDOWN, KEYUP})
    generate_event_wrapper(:text_edit, :edit, {TEXTEDITING})
    generate_event_wrapper(:text_edit_ext, :edit_ext, {TEXTEDITING_EXT})
    generate_event_wrapper(:text_input, :text, {TEXTINPUT})
    generate_event_wrapper(:mouse_motion, :motion, {MOUSEMOTION})
    generate_event_wrapper(:mouse_button, :button, {MOUSEBUTTONDOWN, MOUSEBUTTONUP})
    generate_event_wrapper(:mouse_wheel, :wheel, {MOUSEWHEEL})
    generate_event_wrapper(:joy_axis, :jaxis, {JOYAXISMOTION})
    generate_event_wrapper(:joy_ball, :jball, {JOYBALLMOTION})
    generate_event_wrapper(:joy_hat, :jhat, {JOYHATMOTION})
    generate_event_wrapper(:joy_button, :jbutton, {JOYBUTTONDOWN, JOYBUTTONUP})
    generate_event_wrapper(:joy_device, :jdevice, {JOYDEVICEADDED, JOYDEVICEREMOVED})
    generate_event_wrapper(:joy_battery, :jbattery, {JOYBATTERYUPDATED})
    generate_event_wrapper(:controller_axis, :caxis, {CONTROLLERAXISMOTION})
    generate_event_wrapper(:controller_button, :cbutton, {CONTROLLERBUTTONDOWN, CONTROLLERBUTTONUP})
    generate_event_wrapper(:controller_device, :cdevice, {CONTROLLERDEVICEADDED, CONTROLLERDEVICEREMOVED, CONTROLLERDEVICEREMAPPED})
    generate_event_wrapper(:controller_touchpad, :ctouchpad, {CONTROLLERTOUCHPADDOWN, CONTROLLERTOUCHPADMOTION, CONTROLLERTOUCHPADUP})
    generate_event_wrapper(:controller_sensor, :csensor, {CONTROLLERSENSORUPDATE})
    generate_event_wrapper(:audio_device, :adevice, {AUDIODEVICEADDED, AUDIODEVICEREMOVED})
    generate_event_wrapper(:sensor, :sensor, {SENSORUPDATE})
    generate_event_wrapper(:quit, :quit, {QUIT})
    generate_event_wrapper(:user, :user, {USEREVENT})
    generate_event_wrapper(:syswm, :syswm, {SYSWMEVENT})
    generate_event_wrapper(:touch_finger, :tfinger, {FINGERDOWN, FINGERUP, FINGERMOTION})
    generate_event_wrapper(:multi_gesture, :mgesture, {MULTIGESTURE})
    generate_event_wrapper(:dollar_gesture, :dgesture, {DOLLARGESTURE, DOLLARRECORD})
    generate_event_wrapper(:drop, :drop, {DROPFILE, DROPTEXT, DROPBEGIN, DROPCOMPLETE})
  end
end
