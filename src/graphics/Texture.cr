module Crystal2Day
  class Texture < Crystal2Day::Drawable
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::Texture))

    @renderer : Crystal2Day::Renderer

    getter width : Int32 = 0
    getter height : Int32 = 0

    property offset : Crystal2Day::Coords = Crystal2Day.xy

    def initialize(@renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super()
    end

    def self.load_from_file(filename : String, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      texture = Crystal2Day::Texture.new(renderer)
      texture.load_from_file!(filename)

      return texture
    end

    def load_from_file!(filename : String)
      free

      loaded_surface = LibSDL.img_load(filename)
      Crystal2Day.error "Could not load image from file #{filename}" unless loaded_surface

      @data = LibSDL.create_texture_from_surface(@renderer.data, loaded_surface)
      Crystal2Day.error "Could not create texture from file #{filename}" unless @data

      @width = loaded_surface.value.w
      @height = loaded_surface.value.h

      LibSDL.free_surface(loaded_surface)
    end

    def load_text_from_font!(text : String, font : Crystal2Day::Font, color : Crystal2Day::Color = Crystal2Day::Color.black)
      free

      text_surface = LibSDL.ttf_render_text_solid(font.data, text, color.data)
      Crystal2Day.error "Could not create texture from rendered text" unless text_surface

      @data = LibSDL.create_texture_from_surface(@renderer.data, text_surface)
      Crystal2Day.error "Could not create texture from rendered text surface" unless @data

      @width = text_surface.value.w
      @height = text_surface.value.h

      LibSDL.free_surface(text_surface)
    end

    def raw_boundary_rect(shifted_by : Crystal2Day::Coords = Crystal2Day.xy)
      LibSDL::FRect.new(x: @offset.x + shifted_by.x, y: @offset.y + shifted_by.y, w: @width, h: @height)
    end

    def raw_int_boundary_rect(shifted_by : Crystal2Day::Coords = Crystal2Day.xy)
      LibSDL::Rect.new(x: @offset.x + shifted_by.x, y: @offset.y + shifted_by.y, w: @width, h: @height)
    end

    def renderer_data
      @renderer.data
    end

    def draw_directly
      render_rect = raw_boundary_rect
      LibSDL.render_copy_ex_f(@renderer.data, data, nil, pointerof(render_rect), 0.0, nil, LibSDL::RendererFlip::FLIP_NONE)
    end

    def free
      if @data
        LibSDL.destroy_texture(data)
        @data = nil
        @width = 0
        @height = 0
      end
    end

    def finalize 
      super
      free
    end
  end
end
