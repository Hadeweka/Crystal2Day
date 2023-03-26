# Crystal2Day

Crystal2Day is a 2D game framework in Crystal.

# Description

Crystal2Day (or short C2D) is designed as a tool to develop games with Crystal fast.

It provides basic game functions, but also some typical game design structures like
scenes and entities.

Mostly, it serves as a layer above lower-level game libraries like SDL, without
having to worry about common implementation details.

Currently this project is in an early state, but will be expanded over time.
Note that its syntax may change (frequently) until version 1.0.0.

# Features

* Based on SDL
* Simple framework to immediately start working
* Scene system to organize and streamline game design
* Drawing system with z-ordering

# Prerequisites

* Crystal
* SDL 2

# Installing

Currently, this shard can simply be used by adding it into your `shard.yml`.

Make sure to have SDL installed, or linking will fail.

# A simple example

To get started, here is a simple example, which will simply open an empty window:

```crystal
require "Crystal2Day.cr"

class MyOwnScene < Crystal2Day::Scene
  def handle_event(event)
    if event.type == Crystal2Day::Event::WINDOW
      if event.as_window_event.event == Crystal2Day::WindowEvent::CLOSE
        Crystal2Day.next_scene = nil
      end
    end
  end

  def exit
    Crystal2Day.current_window = nil
  end
end

Crystal2Day.run do
  Crystal2Day::Window.new(title: "Hello World", w: 800, h: 600)
  Crystal2Day.scene = MyOwnScene.new
  Crystal2Day.main_routine
end
```

# Roadmap

## Upcoming releases

### Version 0.0.1

#### Features

* [x] Minimal example
* [ ] Entities
* [ ] Maps
