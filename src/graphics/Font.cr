# A font class for text rendering.

module Crystal2Day
  class Font
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::TTFFont))

    def self.default_font_path
      # NOTE: You should always use your own fonts to prevent this method from failing
      {% if flag?(:win32) %}
        # TODO: Use WINDIR if defined
        "C:/Windows/Fonts/arial.ttf"
      {% else %}
        # TODO: Is there a better way to find this?
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"
      {% end %}
    end

    def initialize

    end

    def self.load_from_file(filename : String, size : Number = 16)
      font = Crystal2Day::Font.new
      font.load_from_file!(filename, size)

      return font
    end

    def load_from_file!(filename : String, size : Number)
      free

      full_filename = Crystal2Day.convert_to_absolute_path(filename)

      @data = LibSDL.ttf_open_font(full_filename, size)
      Crystal2Day.error "Could not font from file #{full_filename}" unless @data
    end

    def free
      if @data
        LibSDL.ttf_close_font(data)
      end
    end

    def calculate_text_rect(text : String)
      LibSDL.ttf_size_text(@data, text, out w, out h)
      Crystal2Day::Rect.new(0, 0, w, h)
    end

    def finalize
      free
    end
  end
end