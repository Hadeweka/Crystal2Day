# A sprite class for more flexibility with textures.
# It allows for geometric operations and serves as a thin layer.

module Crystal2Day
  struct SpriteTemplate
    include JSON::Serializable

    @[JSON::Field(key: "texture")]
    property texture_filename : String = ""

    property position : Crystal2Day::Coords = Crystal2Day.xy
    property source_rect : Crystal2Day::Rect?
    property render_rect : Crystal2Day::Rect?
    property angle : Float32 = 0.0f32
    property center : Crystal2Day::Coords?
    property animation_template : Crystal2Day::AnimationTemplate = Crystal2Day::AnimationTemplate.new
    property parallax : Crystal2Day::Coords = Crystal2Day.xy(1.0, 1.0)
    property z : UInt8 = 0
    property active : Bool = true
    property flip_x : Bool = false
    property flip_y : Bool = false
  end

  class Sprite < Crystal2Day::Drawable
    @texture : Crystal2Day::Texture
    
    property position : Crystal2Day::Coords = Crystal2Day.xy
    property source_rect : Crystal2Day::Rect?
    property render_rect : Crystal2Day::Rect?
    property angle : Float32 = 0.0f32
    property center : Crystal2Day::Coords?
    property animation : Crystal2Day::Animation = Crystal2Day::Animation.new
    property parallax : Crystal2Day::Coords = Crystal2Day.xy(1.0, 1.0)
    property active : Bool = true
    property flip_x : Bool = false
    property flip_y : Bool = false

    def initialize(from_texture : Crystal2Day::Texture = Crystal2Day::Texture.new, source_rect : Crystal2Day::Rect? = nil)
      super()
      @source_rect = source_rect
      @texture = from_texture
    end

    def initialize(sprite_template : Crystal2Day::SpriteTemplate)
      super()
      @texture = Crystal2Day.rm.load_texture(sprite_template.texture_filename)
      @position = sprite_template.position
      @source_rect = sprite_template.source_rect
      @render_rect = sprite_template.render_rect
      @angle = sprite_template.angle
      @center = sprite_template.center
      @animation = Animation.new(sprite_template.animation_template)
      @parallax = sprite_template.parallax
      @z = sprite_template.z
      @flip_x = sprite_template.flip_x
      @flip_y = sprite_template.flip_y
    end

    def update_source_rect_by_frame(frame : UInt16)
      if source_rect = @source_rect
        n_tiles_x = @texture.width // source_rect.width
        source_rect.x = (frame % n_tiles_x) * source_rect.width
        source_rect.y = (frame // n_tiles_x) * source_rect.height
      else
        Crystal2Day.error "No source rect defined"
      end
    end

    def update
      return unless active
      @animation.update
      if @animation.has_changed # TODO: This might likely be discarded
        update_source_rect_by_frame(@animation.current_frame)
      end
    end

    def link_texture(texture : Crystal2Day::Texture)
      @texture = texture
    end

    def draw_directly(offset : Coords)
      return unless active
      final_source_rect = (source_rect = @source_rect) ? source_rect.data : @texture.raw_boundary_rect
      final_offset = @position + @texture.renderer.position_shift.scale(@parallax) + offset
      final_render_rect = (render_rect = @render_rect) ? (render_rect + final_offset).data : (source_rect ? (source_rect.unshifted + final_offset).data : @texture.raw_boundary_rect(shifted_by: final_offset))
      flip_flag = (@flip_x ? LibSDL::FlipMode::HORIZONTAL : LibSDL::FlipMode::NONE) | (@flip_y ? LibSDL::FlipMode::VERTICAL : LibSDL::FlipMode::NONE)
      # TODO: Cache flip flag
      if center = @center
        final_center_point = center.data
        LibSDL.render_texture_rotated(@texture.renderer_data, @texture.data, pointerof(final_source_rect), pointerof(final_render_rect), @angle, pointerof(final_center_point), flip_flag)
      else
        LibSDL.render_texture_rotated(@texture.renderer_data, @texture.data, pointerof(final_source_rect), pointerof(final_render_rect), @angle, nil, flip_flag)
      end
    end
  end
end