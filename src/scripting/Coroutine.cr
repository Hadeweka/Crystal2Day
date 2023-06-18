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

    def active?
      Crystal2Day::Interpreter.check_if_fiber_is_alive(@fiber)
    end
  end

  class ProcCoroutine
    @name : String

    def initialize(@name : String)
    end

    def call(arg : Crystal2Day::Entity)
      Crystal2Day.database.call_entity_proc(@name, arg)
    end
  end

  class CoroutineTemplate
    @proc : Anyolite::RbRef | String | Hash(String, Anyolite::RbRef | String)

    def initialize(@proc : Anyolite::RbRef | String | Hash(String, Anyolite::RbRef | String))
    end

    def generate_hook
      hook = Hook.new
      if @proc.is_a?(Anyolite::RbRef)
        hook.add_page("main", Crystal2Day::Coroutine.new(@proc.as(Anyolite::RbRef)))
      elsif @proc.is_a?(String)
        hook.add_page("main", Crystal2Day::ProcCoroutine.new(@proc.as(String)))
      elsif @proc.is_a?(Hash)
        @proc.as(Hash(String, Anyolite::RbRef | String)).each do |name, value|
          if value.is_a?(Anyolite::RbRef)
            hook.add_page(name, Crystal2Day::Coroutine.new(value.as(Anyolite::RbRef)))
          elsif value.is_a?(String)
            hook.add_page(name, Crystal2Day::ProcCoroutine.new(value.as(String)))
          end
        end
      end
      return hook
    end

    macro from_block(&block)
      Crystal2Day::CoroutineTemplate.new(Anyolite.eval("Proc.new #{{{block.stringify}}}"))
    end

    def self.convert_string_to_ref(string : String, arg_string : String = "")
      Anyolite.eval("Proc.new do |#{arg_string}|\n#{string}\nend")
    end

    # TODO: Add bytecode support

    def self.from_string(string : String, arg_string : String = "")
      Crystal2Day::CoroutineTemplate.new(Crystal2Day::CoroutineTemplate.convert_string_to_ref(string, arg_string))
    end

    def self.from_proc_name(string : String)
      Crystal2Day::CoroutineTemplate.new(string)
    end
    
    def self.from_hashes(string_hash : Hash(String, String), proc_hash : Hash(String, String), arg_string : String = "")
      final_hash = Hash(String, Anyolite::RbRef | String).new(initial_capacity: string_hash.size + proc_hash.size)

      string_hash.each do |name, value|
        final_hash[name] = Crystal2Day::CoroutineTemplate.convert_string_to_ref(value, arg_string)
      end

      proc_hash.each do |name, value|
        final_hash[name] = value
      end

      Crystal2Day::CoroutineTemplate.new(final_hash)
    end

    # TODO: Method to load coroutines from files
  end
end
