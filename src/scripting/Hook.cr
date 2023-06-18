module Crystal2Day
  class Hook
    PAGES_INITIAL_CAPACITY = 8

    @pages = Hash(String, Coroutine | ProcCoroutine).new(initial_capacity: PAGES_INITIAL_CAPACITY)
    @current_page = "main"

    def add_page(name : String, coroutine : Coroutine | ProcCoroutine)
      if @pages[name]?
        Crystal2Day.warning "Coroutine page '#{name}' was defined previously"
      end

      @pages[name] = coroutine
    end

    def change_page(name : String)
      Crystal2Day.error "Unknown coroutine page: '#{name}'" unless @pages[name]?
      @current_page = name
    end

    def call(entity : Entity, entity_ref : Anyolite::RbRef)
      current_page = @pages[@current_page]
      if current_page.is_a?(Coroutine)
        current_page.as(Coroutine).call(entity_ref)
      elsif current_page.is_a?(ProcCoroutine)
        current_page.as(ProcCoroutine).call(entity)
      end
    end
  end
end
