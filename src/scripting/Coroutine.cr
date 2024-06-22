# Coroutines and their templates.
# These are mruby fibers, so they keep their own context and can be suspended at any time.
# Use these for entity behavior scripting.

module Crystal2Day
  class Coroutine
    @fiber : Anyolite::RbRef

    def initialize(template_proc : Anyolite::RbRef)
      @fiber = Crystal2Day::Interpreter.fiber_from_proc(template_proc)
    end

    def call(arg : Crystal2Day::Parameter)
      Crystal2Day::Interpreter.resume_fiber(@fiber, arg) if active?
    end

    def active?
      Crystal2Day::Interpreter.check_if_fiber_is_alive(@fiber)
    end
  end
end
