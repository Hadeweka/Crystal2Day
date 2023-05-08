# A window-specific resource manager.

module Crystal2Day
  class ResourceManager
    TEXTURES_INITIAL_CAPACITY = 256

    @textures = Hash(String, Crystal2Day::Texture).new(initial_capacity: TEXTURES_INITIAL_CAPACITY)
    property renderer : Crystal2Day::Renderer? = nil

    def initialize
    end

    def load_texture(filename)
      unless @textures[filename]?
        texture = Crystal2Day::Texture.new(@renderer.not_nil!)
        texture.load_from_file!(filename)
        @textures[filename] = texture
      end

      @textures[filename]
    end

    def unload_texture(filename)
      @textures[filename].delete if @textures[filename]?
    end

    def unload_all_textures
      @textures.clear
    end

    # TODO: Make macros for all of these
    # TODO: Add fonts, sounds, music, maybe texts
  end
end
