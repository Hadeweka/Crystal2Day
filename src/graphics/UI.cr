# TODO: Finish this
# TODO: Include this into the scene
module Crystal2Day
  class UI < Crystal2Day::Drawable
    property texts : Hash(String, Text) = {} of String => Text
    property position : Crystal2Day::Coords = Crystal2Day.xy

    def draw_directly(offset : Coords)
      # TODO: Draw texts (obviously)
      # TODO: Maybe extend this to include pictures, padding and such?
    end
  end
end
