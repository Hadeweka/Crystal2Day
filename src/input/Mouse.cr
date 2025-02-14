# A module to handle mouse state and input.

module Crystal2Day
  module Mouse
    BUTTON_LEFT = LibSDL::MouseButtonFlags::LEFT.to_u32
    BUTTON_MIDDLE = LibSDL::MouseButtonFlags::MIDDLE.to_u32
    BUTTON_RIGHT = LibSDL::MouseButtonFlags::RIGHT.to_u32
    BUTTON_X1 = LibSDL::MouseButtonFlags::X1.to_u32
    BUTTON_X2 = LibSDL::MouseButtonFlags::X2.to_u32

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
      if window = Crystal2Day.current_window_if_any
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
      LibSDLMacro.button_mask(mouse_state).to_u32 == button
    end

    def self.left_button_down?
      LibSDLMacro.button_mask(LibSDL.get_mouse_state(nil, nil).to_i).to_u32 == BUTTON_LEFT
    end

    def self.right_button_down?
      LibSDLMacro.button_mask(LibSDL.get_mouse_state(nil, nil).to_i).to_u32 == BUTTON_RIGHT
    end

    def self.middle_button_down?
      LibSDLMacro.button_mask(LibSDL.get_mouse_state(nil, nil).to_i).to_u32 == BUTTON_MIDDLE
    end
  end
end
