# A module to handle keyboard state and inputs.

module Crystal2Day
  module Keyboard
    {% for key in LibSDL::Keycode.constants %}
      {{key.id}} = {{LibSDL::Keycode.constant(key)}}
    {% end %}

    @@state : State?

    class State
      @content : UInt8*
      @size : Int32

      def initialize
        @content = LibSDL.get_keyboard_state(out size)
        @size = size
      end

      def key_down?(key : Int)
        if (0 .. (@size - 1)).includes?(key)
          @content[key] != 0
        else
          Crystal2Day.error "Invalid key code: #{key}"
        end
      end
    end

    def self.reset_state
      @@state = State.new()
    end

    def self.state
      @@state.not_nil!
    end

    def self.key_down?(key : LibSDL::Keycode)
      self.reset_state unless @@state
      mod_state = LibSDL.get_mod_state
      @@state.not_nil!.key_down?(LibSDL.get_scancode_from_key(LibSDL::Keycode.new(key), pointerof(mod_state)).to_u32)
    end
  end
end
