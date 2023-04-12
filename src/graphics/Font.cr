# A font class for text rendering.

module Crystal2Day
  class Font
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::TTFFont))

    def initialize

    end

    def self.load_from_file(filename : String, size : Number = 16)
      font = Crystal2Day::Font.new
      font.load_from_file!(filename, size)

      return font
    end

    def load_from_file!(filename : String, size : Number)
      free

      @data = LibSDL.ttf_open_font(filename, size)
      Crystal2Day.error "Could not font from file #{filename}" unless @data
    end

    def free
      if @data
        LibSDL.ttf_close_font(data)
      end
    end

    def finalize
      free
    end
  end
end