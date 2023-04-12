# A color class with some predefined values.

module Crystal2Day
  class Color
    getter data : LibSDL::Color

    def initialize(r : Number = 0, g : Number = 0, b : Number = 0, a : Number = 255)
      @data = LibSDL::Color.new(r: r, g: g, b: b, a: a)
    end

    def r
      @data.r
    end

    def g
      @data.g
    end
    
    def b
      @data.b
    end

    def a
      @data.a
    end

    def r=(value : Number)
      @data.r = value
    end

    def g=(value : Number)
      @data.g = value
    end
    
    def b=(value : Number)
      @data.b = value
    end

    def a=(value : Number)
      @data.a = value
    end

    def self.red
      Crystal2Day::Color.new(255, 0, 0)
    end

    def self.green
      Crystal2Day::Color.new(0, 255, 0)
    end

    def self.blue
      Crystal2Day::Color.new(0, 0, 255)
    end

    def self.black
      Crystal2Day::Color.new(0, 0, 0)
    end

    def self.white
      Crystal2Day::Color.new(255, 255, 255)
    end

    def self.gray
      Crystal2Day::Color.new(128, 128, 128)
    end

    def self.grey
      self.gray
    end

    def self.cyan
      Crystal2Day::Color.new(0, 255, 255)
    end

    def self.magenta
      Crystal2Day::Color.new(255, 0, 255)
    end

    def self.yellow
      Crystal2Day::Color.new(255, 255, 0)
    end

    def self.transparent
      Crystal2Day::Color.new(0, 0, 0, 0)
    end
  end
end