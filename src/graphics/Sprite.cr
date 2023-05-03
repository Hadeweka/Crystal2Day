# A sprite class for more flexibility with textures.
# It allows for geometric operations and serves as a thin layer.

module Crystal2Day
  class Sprite < Crystal2Day::Drawable
    @texture : Crystal2Day::Texture
    
    property position : Crystal2Day::Coords = Crystal2Day.xy
    property source_rect : Crystal2Day::Rect?
    property render_rect : Crystal2Day::Rect?
    property angle : Float32 = 0.0f32
    property center : Crystal2Day::Coords?
    property animation : Crystal2Day::Animation = Crystal2Day::Animation.new

    def initialize(from_texture : Crystal2Day::Texture = Crystal2Day::Texture.new, source_rect : Crystal2Day::Rect? = nil)
      super()
      @source_rect = source_rect
      @texture = from_texture
    end

    def dup
      new_sprite = Sprite.new(from_texture: @texture, source_rect: @source_rect.dup)
      new_sprite.position = @position.dup
      new_sprite.render_rect = @render_rect.dup
      new_sprite.angle = @angle
      new_sprite.center = @center.dup
      new_sprite.z = @z
      new_sprite.animation = Animation.new(@animation.template)
      new_sprite
    end

    def update_source_rect_by_frame(frame : UInt16)
      # TODO: This currently only works for texture stripes, but not squares
      if source_rect = @source_rect
        source_rect.x = source_rect.width * frame
      else
        Crystal2Day.error "No source rect defined"
      end
    end

    def update
      @animation.update
      if @animation.has_changed
        update_source_rect_by_frame(@animation.current_frame)
      end
    end

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end

    def draw_directly(offset : Coords)
      final_source_rect = (source_rect = @source_rect) ? source_rect.int_data : @texture.raw_int_boundary_rect
      final_offset = @position + @texture.renderer.position_shift + offset
      final_render_rect = (render_rect = @render_rect) ? (render_rect + final_offset).data : (source_rect ? (source_rect.unshifted + final_offset).data : @texture.raw_boundary_rect(shifted_by: final_offset))
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