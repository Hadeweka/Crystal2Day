module Crystal2Day
  class CoroutineTemplate
    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      @proc : Anyolite::RbRef | String | Hash(String, Anyolite::RbRef | String)
    {% else %}
      @proc : String | Hash(String, String)
    {% end %}

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def initialize(@proc : Anyolite::RbRef | String | Hash(String, Anyolite::RbRef | String))
      end
    {% else %}
      def initialize(@proc : String | Hash(String, String))
      end
    {% end %}

    def generate_hook
      hook = Hook.new
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        if @proc.is_a?(Anyolite::RbRef)
          hook.add_page("main", Crystal2Day::Coroutine.new(@proc.as(Anyolite::RbRef)))
        end
      {% end %}
      if @proc.is_a?(String)
        hook.add_page("main", Crystal2Day::ProcCoroutine.new(@proc.as(String)))
      elsif @proc.is_a?(Hash)
        {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
          @proc.as(Hash(String, Anyolite::RbRef | String)).each do |name, value|
            if value.is_a?(Anyolite::RbRef)
              hook.add_page(name, Crystal2Day::Coroutine.new(value.as(Anyolite::RbRef)))
            elsif value.is_a?(String)
              hook.add_page(name, Crystal2Day::ProcCoroutine.new(value.as(String)))
            end
          end
        {% else %}
          @proc.as(Hash(String, String)).each do |name, value|
            hook.add_page(name, Crystal2Day::ProcCoroutine.new(value))
          end
        {% end %}
      end
      return hook
    end

    macro from_block(&block)
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        Crystal2Day::CoroutineTemplate.new(Anyolite.eval("Proc.new #{{{block.stringify}}}"))
      {% else %}
        raise "Coroutines from blocks are only avilable with Anyolite support"
      {% end %}
    end

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def self.convert_string_to_ref(string : String, arg_string : String = "")
        Anyolite.eval("Proc.new do |#{arg_string}|\n#{string}\nend")
      end
    {% end %}

    # TODO: Add bytecode support

    def self.from_string(string : String, arg_string : String = "")
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        Crystal2Day::CoroutineTemplate.new(Crystal2Day::CoroutineTemplate.convert_string_to_ref(string, arg_string))
      {% else %}
        raise "Coroutines from strings are only avilable with Anyolite support"
      {% end %}
    end

    def self.from_proc_name(string : String)
      Crystal2Day::CoroutineTemplate.new(string)
    end
    
    def self.from_hashes(string_hash : Hash(String, String), proc_hash : Hash(String, String), arg_string : String = "")
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        final_hash = Hash(String, Anyolite::RbRef | String).new(initial_capacity: string_hash.size + proc_hash.size)

        string_hash.each do |name, value|
          final_hash[name] = Crystal2Day::CoroutineTemplate.convert_string_to_ref(value, arg_string)
        end

        proc_hash.each do |name, value|
          final_hash[name] = value
        end

        Crystal2Day::CoroutineTemplate.new(final_hash)
      {% else %}
        final_hash = Hash(String, String).new(initial_capacity: proc_hash.size)

        proc_hash.each do |name, value|
          final_hash[name] = value
        end

        Crystal2Day::CoroutineTemplate.new(final_hash)
      {% end %}
    end

    # TODO: Method to load coroutines from files
  end
end
