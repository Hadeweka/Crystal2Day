module Crystal2Day
  class Scene
    property use_own_draw_implementation : Bool = false

    def initialize
    end

    def process_events
      Crystal2Day.poll_events do |event|
        handle_event(event.not_nil!)
      end
    end

    def handle_event(event)
    end

    def main_update
    end

    def main_draw
    end

    def init
    end

    def exit
    end

    def main_draw
      if @use_own_draw_implementation
        call_inner_draw_block
      elsif win = Crystal2Day.current_window
        win.clear
        call_inner_draw_block
        win.render_and_display
      end
    end

    def call_inner_draw_block
      # TODO: Draw entities here
    end
  end
end
