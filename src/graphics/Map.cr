module Crystal2Day
  alias TileID = UInt32

  class Map < Crystal2Day::Drawable
    #@tiles : Array(Array(TileID))
    #@width : UInt32
    #@height : UInt32

    # TODO: Add shiftable vertex grid
    # TODO: Add content

    def initialize(renderer : Crystal2Day::Renderer = Crystal2Day.current_window.not_nil!.renderer)
      super(renderer)
    end

    def draw_directly
      # int SDL_RenderGeometry(SDL_Renderer *renderer,
      # SDL_Texture *texture,
      # const SDL_Vertex *vertices, int num_vertices,
      # const int *indices, int num_indices);
    end
  end
end
