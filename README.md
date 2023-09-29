# What is Crystal2Day?

Crystal2Day is designed as a tool to develop games with Crystal fast.

Less work for you, therefore more time for actual game design.

# Why should I use Crystal2Day?

Did you ever want to start a game, but then got frustrated while programming something
mundane like a scrolling map, finally implemented it and then gave up when you saw the
terrifying news of "20 FPS"?

Then Crystal2Day might just be the solution for you.

Crystal2Day is more than just a Crystal wrapper around a media library. 

It provides basic game functions, but also some typical game design structures like
maps, scenes and entities.

Mostly, it serves as a layer above lower-level game libraries like SDL, without
having to worry about common implementation details.

For example, a map class is already implemented, as well as typical collision routines,
a framerate limiter, z-ordering, cameras and many other things.

And even if you want to do everything by yourself, you can just do exactly that, as
most SDL functions are available in this library.

Currently this project is in an early state, but will be expanded over time.
Note that its syntax may change (frequently) until version 1.0.0.

# Features

## Main features

* Based on SDL
* Simple framework to immediately start working
* Scene system to organize and streamline game design
* Already implemented: Cameras, z-ordering, parallax scrolling, maps, collisions, ...
* Data-driven entitiy system

## Optional features

* Behavior scripting using mruby via Anyolite
* Simple GUI construction (e.g. for debugging) using Dear ImGui

# Prerequisites

## Essential

* Crystal (obviously)
* SDL 2 (media library; SDL 3 is not yet supported)

## Optional

* Git (for installing additional features)
* GCC or Microsoft Visual Studio (for installing additional features)
* Ruby (for installing additional features)
* Rake (for installing additional features)

# Installing

Currently, this shard can simply be used by adding it into your `shard.yml`,
as long as all dependencies are installed correctly.

Make sure to have SDL 2 and its libraries installed, or linking will fail.

If you want to add features like Anyolite or ImGui,
you can install them using `rake add_feature_XXX`, where `XXX` is one of the
following features:

* anyolite - Support for scripting using mruby
* imgui - A simple GUI application, useful for debugging

It is also possible to install these manually. Crystal2Day will automatically
include these features, if they are found in the `lib` directory (for example
after installing them as shards together with Crystal2Day).

NOTE: ImGui currently only works on Windows AND you either need to copy both
`cimgui.dll` and `cimgui.lib` from the Crystal2Day directory to your working directory or set the Crystal
environmental variables so that they are included.

# A simple example

To get started, here is a simple example, which will simply open an empty window:

```crystal
require "Crystal2Day.cr"

# Just create a customized Scene class
class MyOwnScene < Crystal2Day::Scene
  # Any events are passed to this method
  def handle_event(event)
    if event.type == Crystal2Day::Event::WINDOW
      if event.as_window_event.event == Crystal2Day::WindowEvent::CLOSE
        # Signal the program to stop the main loop
        Crystal2Day.next_scene = nil
      end
    end
  end
end

# All setup for the framework is done in this block
Crystal2Day.run do
  # If we only have one window, the framework stores a reference to it
  Crystal2Day::Window.new(title: "Hello World", w: 800, h: 600)
  # Set the next scene
  Crystal2Day.scene = MyOwnScene.new
  # Start the game
  Crystal2Day.main_routine
end
```

# Roadmap

## Version releases

### Version 0.1.0

#### Features

* Music and sounds
* Textures, sprites, fonts, texts
* Basic shapes (points, lines, boxes, circles, triangles, ellipses)
* Z-Ordering
* Scene system
* Support for multiple windows
* Framerate limiter
* Maps and tilesets
* 2D collision routines
* Entity hook scripting in mruby using and Anyolite
* Entities with flexible states and multiple script pages
* Entity collision system
* Simple game state
* Resource management system
* Special plugin system
* Imgui support
* [ ] Text alignment options

### Version 1.0.0

#### Features

* [ ] Documentation

### Idea list for future versions

#### Features

* [ ] Game controller support
* [ ] Tile animation
* [ ] Entity parent-children system with memory management
* [ ] Custom shape designs (colors, textures)
* [ ] Quadriliteral shapes
* [ ] Map optimization using quadtrees
* [ ] Loading scenes and related objects from JSON files
* [ ] Also allow symbols as Crystal hash indices
* [ ] Tiled support
* [ ] Particle generator
* [ ] Hitshapes and hurtshapes
* [ ] Bytecode loading
* [ ] Adding static JSON resources at compiletime
* [ ] Data serializing
* [ ] Data obfuscation
* [ ] Animation phase shift patterns
* [ ] Collision routines for layered maps
* [ ] Various optimizations
