# The collection of all files for Crystal2Day.
# Any deviation from alphabetic order is intended.

require "json"

require "sdl-crystal-bindings"
require "sdl-crystal-bindings/sdl-mixer-bindings"
require "sdl-crystal-bindings/sdl-image-bindings"
require "sdl-crystal-bindings/sdl-ttf-bindings"

require "anyolite"
ANYOLITE_DEFAULT_OPTIONAL_ARGS_TO_KEYWORD_ARGS = true

require "./base/Coords.cr"
require "./base/Helper.cr"
require "./base/Main.cr"
require "./base/Rect.cr"
require "./base/ResourceManager.cr"

require "./scripting/Interpreter.cr"

require "./scripting/Coroutine.cr"

require "./audio/Music.cr"
require "./audio/Sound.cr"

require "./graphics/Drawable.cr"

require "./graphics/Animation.cr"
require "./graphics/Camera.cr"
require "./graphics/Color.cr"
require "./graphics/Font.cr"
require "./graphics/Map.cr"
require "./graphics/Renderer.cr"
require "./graphics/RenderQueue.cr"
require "./graphics/Shapes.cr"
require "./graphics/Sprite.cr"
require "./graphics/Text.cr"
require "./graphics/Texture.cr"
require "./graphics/Tileset.cr"
require "./graphics/View.cr"
require "./graphics/Window.cr"

require "./game/Collishi.cr"
require "./game/CollisionShapes.cr"
require "./game/Entity.cr"
require "./game/EntityGroup.cr"
require "./game/EntityType.cr"
require "./game/GameData.cr"
require "./game/Limiter.cr"
require "./game/Scene.cr"

require "./input/Event.cr"
require "./input/Keyboard.cr"
require "./input/Mouse.cr"
