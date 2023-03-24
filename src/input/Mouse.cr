module Crystal2Day
  module Mouse
    BUTTON_LEFT = LibSDL::BUTTON_LEFT
    BUTTON_MIDDLE = LibSDL::BUTTON_MIDDLE
    BUTTON_RIGHT = LibSDL::BUTTON_RIGHT
    BUTTON_X1 = LibSDL::BUTTON_X1
    BUTTON_X2 = LibSDL::BUTTON_X2

    def self.position_change
      LibSDL.get_relative_mouse_state(out x, out y)
      Crystal2Day::Coords.new(x, y)
    end

    def self.position
      LibSDL.get_mouse_state(out x, out y)
      Crystal2Day::Coords.new(x, y)
    end

    def self.global_position
      LibSDL.get_global_mouse_state(out x, out y)
      Crystal2Day::Coords.new(x, y)
    end

    def self.position=(pos : Crystal2Day::Coords)
      if window = Crystal2Day.current_window.not_nil!
        LibSDL.warp_mouse_in_window(window.data, pos.x, pos.y)
      else
        Crystal2Day.error "Could not set position in closed or invalid window"
      end
    end

    def self.global_position=(pos : Crystal2Day::Coords)
      LibSDL.warp_mouse_global(pos.x, pos.y)
    end

    def self.focused_window
      Crystal2Day.get_mouse_focused_window
    end

    def self.button_down?(button : Int)
      mouse_state = LibSDL.get_mouse_state(nil, nil).to_i
      LibSDLMacro.button(mouse_state) == button
    end

    def self.left_button_down?
      LibSDLMacro.button(LibSDL.get_mouse_state(nil, nil).to_i) == LibSDL::BUTTON_LEFT
    end

    def self.right_button_down?
      LibSDLMacro.button(LibSDL.get_mouse_state(nil, nil).to_i) == LibSDL::BUTTON_RIGHT
    end

    def self.middle_button_down?
      LibSDLMacro.button(LibSDL.get_mouse_state(nil, nil).to_i) == LibSDL::BUTTON_MIDDLE
    end
  end
end
