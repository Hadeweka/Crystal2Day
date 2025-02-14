module Crystal2Day
  # TDOO: Maybe change the names of the methods
  # TODO: Somehow support mouse clicks and controller buttons as well
  # TODO: Support config files

  class InputManager
    KEY_TABLE_INITIAL_CAPACITY = 32

    @key_table = Hash(String, Array(UInt32)).new(initial_capacity: KEY_TABLE_INITIAL_CAPACITY)

    def set_key_table_entry(name : String, keys : Array(UInt32))
      @key_table[name] = keys
    end

    def clear
      @key_table.clear
    end

    def key_down?(name : String)
      return false unless @key_table[name]?

      @key_table[name].each do |actual_key|
        return true if Crystal2Day::Keyboard.key_down?(LibSDL::Keycode.new(actual_key))
      end
      false
    end

    def check_event_for_key_press(event : Crystal2Day::Event, name : String)
      if event.type == Crystal2Day::Event::KEY_DOWN
        return false unless @key_table[name]?

        @key_table[name].each do |actual_key|
          return true if actual_key.to_u32 == event.as_key_event.key.to_u32
        end
        false
      else
        false
      end
    end
  end
end
