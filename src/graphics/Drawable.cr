module Crystal2Day
  abstract class Drawable
    getter z : UInt8 = 0
    getter pinned : Bool = false

    def draw
      if window = Crystal2Day.current_window
        window.draw(self)
      else
        Crystal2Day.error "Could not draw to closed or invalid window"
      end
    end

    def finalize
      unpin if @pinned
    end

    def z=(value : Int)
      if value != @z
        if @pinned
          unpin
          @z = value.to_u8
          pin
        end
      end
    end

    def pin
      @pinned = true
      if window = Crystal2Day.current_window
        window.pin(self)
      else
        Crystal2Day.error "Could not pin to closed or invalid window"
      end
    end

    def unpin
      @pinned = false
      if window = Crystal2Day.current_window
        window.unpin(self)
      else
        Crystal2Day.error "Could not unpin from closed or invalid window"
      end
    end

    abstract def draw_directly
  end
end
