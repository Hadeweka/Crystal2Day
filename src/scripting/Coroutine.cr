# Coroutines and their templates.
# These are mruby fibers, so they keep their own context and can be suspended at any time.
# Use these for entity behavior scripting.

module Crystal2Day
  class Coroutine
    @fiber : Anyolite::RbRef

    def initialize(template_proc : Anyolite::RbRef)
      @fiber = Crystal2Day::Interpreter.fiber_from_proc(template_proc)
    end

    def call(arg : Anyolite::RbRef)
      Crystal2Day::Interpreter.resume_fiber(@fiber, arg) if active?
    end

    # TODO: Maybe support more than two args?

    def call(arg : Anyolite::RbRef, second_arg : Anyolite::RbRef)
      Crystal2Day::Interpreter.resume_fiber(@fiber, arg, second_arg) if active?
    end

    def active?
      Crystal2Day::Interpreter.check_if_fiber_is_alive(@fiber)
    end
  end

  class CoroutineTemplate
    @proc : Anyolite::RbRef

    def initialize(@proc : Anyolite::RbRef)
    end

    def generate_hook
      return Crystal2Day::Coroutine.new(@proc)
    end

    macro from_block(&block)
      Crystal2Day::CoroutineTemplate.new(Anyolite.eval("Proc.new #{{{block.stringify}}}"))
    end

    # TODO: Add bytecode support

    def self.from_string(string : String, arg_string : String = "")
      Crystal2Day::CoroutineTemplate.new(Anyolite.eval("Proc.new do |#{arg_string}|\n#{string}\nend"))
    end

    # TODO: Method to load coroutines from files
  end
end
