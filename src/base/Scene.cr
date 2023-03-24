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
  end
end
