module Crystal2Day
  class ProcCoroutine
    @name : String

    def initialize(@name : String)
    end

    def call(arg : Crystal2Day::Entity)
      Crystal2Day.database.call_entity_proc(@name, arg)
    end
  end
end
