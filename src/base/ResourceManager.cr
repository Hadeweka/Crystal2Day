# A window-specific resource manager.

module Crystal2Day
  class ResourceManager
    macro add_resource_type(name, resource_class, initial_capacity, additional_arg = nil, plural = "s")
      @{{(name + plural).id}} = Hash(String, Crystal2Day::{{resource_class}}).new(initial_capacity: {{initial_capacity}})

      def load_{{name.id}}(filename : String, additional_tag : String = "")
        unless @{{(name + plural).id}}[filename + additional_tag]?
          {% if additional_arg %}
            {{name.id}} = Crystal2Day::{{resource_class}}.new({{additional_arg}})
          {% else %}
            {{name.id}} = Crystal2Day::{{resource_class}}.new
          {% end %}
          {{name.id}}.load_from_file!(filename)
          @{{(name + plural).id}}[filename + additional_tag] = {{name.id}}
        end

        @{{(name + plural).id}}[filename + additional_tag]
      end

      def unload_{{name.id}}(filename : String, additional_tag : String = "")
        @{{(name + plural).id}}[filename + additional_tag].delete if @{{(name + plural).id}}[filename + additional_tag]?
      end
  
      def unload_all_{{(name + plural).id}}
        @{{(name + plural).id}}.clear
      end
    end

    TEXTURES_INITIAL_CAPACITY = 256
    SOUNDS_INITIAL_CAPACITY = 256
    MUSICS_INITIAL_CAPACITY = 256
    
    property renderer : Crystal2Day::Renderer? = nil

    add_resource_type("texture", Texture, TEXTURES_INITIAL_CAPACITY, additional_arg: @renderer.not_nil!)
    add_resource_type("sound", Sound, SOUNDS_INITIAL_CAPACITY)
    add_resource_type("music", Music, MUSICS_INITIAL_CAPACITY, plural: "")

    def initialize
    end

    # TODO: Add Fonts and maybe texts
  end
end
