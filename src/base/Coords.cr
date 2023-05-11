# A coordinate class, which essentially represents a 2D vector or point.

module Crystal2Day
  class Coords
    getter data : LibSDL::FPoint
    
    @[Anyolite::Specialize]
    def initialize(x : Number = 0.0, y : Number = 0.0)
      @data = LibSDL::FPoint.new(x: x, y: y)
    end

    def initialize(pull : JSON::PullParser)
      @data = LibSDL::FPoint.new(x: 0.0, y: 0.0)

      pull.read_object do |key|
        case key
        when "x" then self.x = pull.read_float
        when "y" then self.y = pull.read_float
        end
      end
    end

    def to_json(json : JSON::Builder)
      # TODO
    end

    def dup
      Coords.new(x, y)
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

    def +(other : Crystal2Day::Coords)
      Crystal2Day::Coords.new(self.x + other.x, self.y + other.y)
    end

    def -(other : Crystal2Day::Coords)
      Crystal2Day::Coords.new(self.x - other.x, self.y - other.y)
    end

    def *(scalar : Number)
      Crystal2Day::Coords.new(self.x * scalar, self.y * scalar)
    end

    def scale(other : Crystal2Day::Coords)
      Crystal2Day::Coords.new(self.x * other.x, self.y * other.y)
    end

    def /(scalar : Number)
      Crystal2Day::Coords.new(self.x / scalar, self.y / scalar)
    end

    def dot(other : Crystal2Day::Coords)
      self.x * other.x + self.y * other.y
    end

    def squared_norm
      self.dot(self)
    end

    # Some synonyms

    def norm
      Math.sqrt(squared_norm)
    end

    def abs
      norm
    end

    def magnitude
      norm
    end

    def angle_to(other : Crystal2Day::Coords)
      Math.acos(self.dot(other) / (self.norm * other.norm))
    end

    def angle
      Math.atan2(self.y, self.x)
    end

    def to_s
      "(#{self.x} | #{self.y})"
    end

    def int_data
      LibSDL::Point.new(x: self.x, y: self.y)
    end
  end

  def self.xy(x : Number = 0.0, y : Number = 0.0)
    Crystal2Day::Coords.new(x, y)
  end
end
