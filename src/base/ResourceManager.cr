module Crystal2Day
  class ResourceManager
    TEXTURES_INITIAL_CAPACITY = 256

    @textures = Hash(String, Crystal2Day::Texture).new(initial_capacity: TEXTURES_INITIAL_CAPACITY)

    def load_texture(filename, name : String? = nil, renderer : Crystal2Day::Renderer = Crystal2Day.current_window.renderer)
      index_name = name ? name.not_nil! : "UNNAMED_#{filename.hash}"

      unless @textures[index_name]?
        texture = Crystal2Day::Texture.new(renderer)
        texture.load_from_file!(filename)
        @textures[index_name] = texture
      end

      @textures[index_name]
    end

    def unload_texture(name)
      @textures[name].delete if @textures[name]?
    end

    def unload_all_textures
      @textures.clear
    end

    # TODO: Make macros for all of these
    # TODO: Add fonts, sounds, music, maybe texts
  end
end