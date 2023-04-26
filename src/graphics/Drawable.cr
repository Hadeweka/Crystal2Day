# The abstract base class for any drawable objects.
# If you want to implement your own `Drawable`, you need to provide some way to draw it directly.

module Crystal2Day
  abstract class Drawable
    getter z : UInt8 = 0
    getter pinned : Bool = false

    def draw(offset : Coords = Crystal2Day.xy)
      if window = Crystal2Day.current_window_if_any
        window.draw(self, offset)
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
        else
          @z = value.to_u8
        end
      end
    end

    def pin(offset : Coords = Crystal2Day.xy)
      @pinned = true
      if window = Crystal2Day.current_window_if_any
        window.pin(self, offset)
      else
        Crystal2Day.error "Could not pin to closed or invalid window"
      end
    end

    def unpin(offset : Coords = Crystal2Day.xy)
      @pinned = false
      if window = Crystal2Day.current_window_if_any
        window.unpin(self, offset)
      else
        Crystal2Day.error "Could not unpin from closed or invalid window"
      end
    end

    abstract def draw_directly(offset : Coords)
  end
end
