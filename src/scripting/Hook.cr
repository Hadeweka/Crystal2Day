module Crystal2Day
  class Hook
    PAGES_INITIAL_CAPACITY = 8

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      @pages = Hash(String, Coroutine | ProcCoroutine).new(initial_capacity: PAGES_INITIAL_CAPACITY)
    {% else %}
      @pages = Hash(String, ProcCoroutine).new(initial_capacity: PAGES_INITIAL_CAPACITY)
    {% end %}
    @current_page = "main"

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def add_page(name : String, coroutine : Coroutine | ProcCoroutine)
        if @pages[name]?
          Crystal2Day.warning "Coroutine page '#{name}' was defined previously"
        end
  
        @pages[name] = coroutine
      end
    {% else %}
      def add_page(name : String, coroutine : ProcCoroutine)
        if @pages[name]?
          Crystal2Day.warning "Coroutine page '#{name}' was defined previously"
        end

        @pages[name] = coroutine
      end
    {% end %}

    def is_currently_ruby?
      {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
        @pages[@current_page].is_a?(Coroutine)
      {% else %}
        false
      {% end %}
    end

    def change_page(name : String)
      Crystal2Day.error "Unknown coroutine page: '#{name}'" unless @pages[name]?
      @current_page = name
    end

    {% if CRYSTAL2DAY_CONFIGS_ANYOLITE %}
      def call(entity : Entity, entity_ref : Anyolite::RbRef)
        current_page = @pages[@current_page]
        if current_page.is_a?(Coroutine)
          current_page.as(Coroutine).call(entity_ref)
        elsif current_page.is_a?(ProcCoroutine)
          current_page.as(ProcCoroutine).call(entity)
        end
      end
    {% else %}
      def call(entity : Entity)
        current_page = @pages[@current_page]
        current_page.as(ProcCoroutine).call(entity)
      end
    {% end %}
  end
end
