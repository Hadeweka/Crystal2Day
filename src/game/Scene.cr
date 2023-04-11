module Crystal2Day
  class Scene
    property use_own_draw_implementation : Bool = false

    def handle_event(event)
    end

    def init
    end

    def exit
    end

    def update
    end

    def draw
    end

    def initialize
    end

    def process_events
      Crystal2Day.poll_events do |event|
        handle_event(event.not_nil!)
      end
    end

    def main_update
      update
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
    end

    def call_inner_draw_block
      draw
      # TODO: Draw entities here
    end
  end
end
