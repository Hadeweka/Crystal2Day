module Crystal2Day
  alias AtomicParamTypes = Nil | Bool | Int32 | Int64 | Float32 | Float64 | String | Crystal2Day::Coords | Crystal2Day::Rect | Crystal2Day::Color | Crystal2Day::CollisionShape
  alias ParamType = AtomicParamTypes | Array(ParamType)

  {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
    alias Parameter = Anyolite::RbRef
  {% else %}
    class Parameter
      @content : ParamType

      def intitialize(@content : ParamType)
      end

      def to_b
        @content.as(Bool)
      end

      def to_i
        @content.as(Int)
      end

      def to_i32
        @content.as(Int32)
      end

      def to_f
        @content.as(Float)
      end

      def to_f32
        @content.as(Float32)
      end

      def to_s
        @content.as(String)
      end

      def to_coords
        @content.as(Crystal2Day::Coords)
      end

      def to_xy
        to_coords
      end

      def to_rect
        @content.as(Crystal2Day::Rect)
      end

      def to_color
        @content.as(Crystal2Day::Color)
      end

      def to_shape
        @content.as(Crystal2Day::CollisionShape)
      end
    end
  {% end %}
end
