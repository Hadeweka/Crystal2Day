require "anyolite"

ANYOLITE_DEFAULT_OPTIONAL_ARGS_TO_KEYWORD_ARGS = true

module Crystal2Day
  module Interpreter
    @@rb_interpreter : Anyolite::RbInterpreter? = nil

    macro expose_class(class_or_module, under = nil)
      Anyolite.wrap(Crystal2Day::Interpreter.get, {{class_or_module}}, under: {{under}})
    end

    def self.start
      if @@rb_interpreter
        Crystal2Day.error "An interpreter instance already exists."
      else
        @@rb_interpreter = Anyolite::RbInterpreter.new
        Anyolite::HelperClasses.load_all(Crystal2Day::Interpreter.get)
      end
    end
  
    def self.close
      if rb = @@rb_interpreter
        rb.close
        @@rb_interpreter = nil
      else
        Crystal2Day.warning "No interpreter instance found."
      end
    end
  
    def self.active?
      !!@@rb_interpreter
    end

    def self.get
      @@rb_interpreter.not_nil!
    end

    def self.generate_ref(value)
      raw_ref = Anyolite::RbCast.return_value(Crystal2Day::Interpreter.get.to_unsafe, value)
      Anyolite::RbRef.new(raw_ref)
    end

    def self.inspect_ref(value : Anyolite::RbRef)
      ruby_str = Anyolite::RbCore.rb_inspect(Crystal2Day::Interpreter.get.to_unsafe, value.value)
      Anyolite::RbCast.cast_to_string(Crystal2Day::Interpreter.get.to_unsafe, ruby_str)
    end

    macro cast_ref_to(value, crystal_class)
      Anyolite::Macro.convert_from_ruby_to_crystal(Crystal2Day::Interpreter.get.to_unsafe, {{value}}, {{crystal_class}})
    end
  end
end