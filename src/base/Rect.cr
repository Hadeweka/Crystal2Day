# A class for passing rectangle data.
# This is not to be confused with drawable rectangles and collision boxes.

module Crystal2Day
  class Rect
    getter data : LibSDL::FRect

    def initialize(x : Number = 0.0, y : Number = 0.0, width : Number = 0.0, height : Number = 0.0)
      @data = LibSDL::FRect.new(x: x, y: y, w: width, h: height)
    end

    def +(vector : Crystal2Day::Coords)
      Crystal2Day::Rect.new(x: self.x + vector.x, y: self.y + vector.y, width: self.width, height: self.height)
    end

    def *(value : Number)
      Crystal2Day::Rect.new(x: x, y: y, width: self.width * value, height: self.height * value)
    end

    def x
      @data.x
    end

    def x=(value : Number)
      @data.x = value
    end

    def y
      @data.y
    end

    def y=(value : Number)
      @data.y = value
    end

    def width
      @data.w
    end

    def width=(value : Number)
      @data.w = value
    end

    def height
      @data.h
    end

    def height=(value : Number)
      @data.h = value
    end

    def int_data
      LibSDL::Rect.new(x: self.x, y: self.y, w: self.width, h: self.height)
    end
  end
end