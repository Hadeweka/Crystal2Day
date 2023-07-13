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

* Based on SDL
* Simple framework to immediately start working
* Scene system to organize and streamline game design
* Already implemented: Cameras, z-ordering, parallax scrolling, maps, collisions, ...
* Data-driven entitiy system with mruby behavior scripting

# Prerequisites

* Crystal (obviously)
* SDL 2 (media library; SDL 3 is not yet supported)
* Git (for installing Anyolite)
* GCC or Microsoft Visual Studio (for installing Anyolite)
* Ruby (for installing Anyolite)
* Rake (for installing Anyolite)

# Installing

Currently, this shard can simply be used by adding it into your `shard.yml`,
as long as all dependencies are installed correctly.

Make sure to have SDL 2 and its libraries installed, or linking will fail.

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

* [X] Music and sounds
* [X] Textures, sprites, fonts, texts
* [X] Basic shapes (points, lines, boxes, circles, triangles, ellipses)
* [X] Z-Ordering
* [X] Scene system
* [X] Support for multiple windows
* [X] Framerate limiter
* [X] Maps and tilesets
* [X] 2D collision routines
* [X] Entity hook scripting in mruby using and Anyolite
* [X] Entities with flexible states and multiple script pages
* [X] Entity collision system
* [X] Simple game state
* [X] Resource management system

#### Todo list

##### Controls

* [ ] Controller support

##### Maps

* [ ] Loading routines

##### Graphics

* [ ] Tile animation
* [ ] Simple sprite scaling and centering

### Version 1.0.0

#### Features

* [ ] Documentation

### Idea list for future versions

#### Features

* [ ] Entity parent-children system with memory management
* [ ] Custom shape designs (colors, textures)
* [ ] Quadriliteral shapes
* [ ] Map optimization using quadtrees
* [ ] Loading scenes and related objects from JSON files
* [ ] Also allow symbols as Crystal hash indices
* [ ] Tiled support
* [ ] Particle generator
* [ ] Hitshapes and hurtshapes
* [ ] Text alignment options
* [ ] ImGUI support
* [ ] Bytecode loading
* [ ] Adding static JSON resources at compiletime
* [ ] Data serializing
* [ ] Data obfuscation
* [ ] Animation phase shift patterns
* [ ] Various optimizations