module Crystal2DayHelper
  macro wrap_type(x)
    @data : {{x}}?
    
    def data
      if data = @data
        data.not_nil!
      else
        Crystal2Day.error "Internal data of type {{x}} was used after being reset"
      end
    end

    def data?
      !!@data
    end
  end
end
