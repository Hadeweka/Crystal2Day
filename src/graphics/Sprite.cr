module Crystal2Day
  class Sprite < Crystal2Day::Drawable
    @texture : Crystal2Day::Texture
    
    property position : Crystal2Day::Coords = Crystal2Day.xy
    property source_rect : Crystal2Day::Rect?
    property render_rect : Crystal2Day::Rect?
    property angle : Float32 = 0.0f32
    property center : Crystal2Day::Coords?

    def initialize(from_texture : Crystal2Day::Texture = Crystal2Day::Texture.new, source_rect : Crystal2Day::Rect? = nil)
      super()
      @source_rect = source_rect
      @texture = from_texture
    end

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end

    def draw_directly
      final_source_rect = (source_rect = @source_rect) ? source_rect.int_data : @texture.raw_int_boundary_rect
      final_render_rect = (render_rect = @render_rect) ? (render_rect + @position + @texture.renderer.position_shift).data : @texture.raw_boundary_rect(shifted_by: @position + @texture.renderer.position_shift)
      flip_flag = LibSDL::RendererFlip::FLIP_NONE
      if center = @center
        final_center_point = center.data
        LibSDL.render_copy_ex_f(@texture.renderer_data, @texture.data, pointerof(final_source_rect), pointerof(final_render_rect), @angle, pointerof(final_center_point), flip_flag)
      else
        LibSDL.render_copy_ex_f(@texture.renderer_data, @texture.data, pointerof(final_source_rect), pointerof(final_render_rect), @angle, nil, flip_flag)
      end
    end
  end
end