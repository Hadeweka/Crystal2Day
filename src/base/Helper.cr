# Helper classes

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

class Object
  def Object.from_json_file(filename : String)
    result = uninitialized self
    File.open(filename, "r") do |f|
      result = self.from_json(f)
    end
    return result
  end
end
