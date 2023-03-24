module Crystal2Day
  class Music
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::MixMusic))

    class_getter current_music : Crystal2Day::Music?

    getter volume : Int32 = Crystal2Day::MAX_VOLUME
    
    @playing : Bool = false

    def initialize

    end

    def current_music?
      @@current_music == self
    end

    def volume=(value : Number)
      @volume = value.to_i32
      LibSDL.mix_volume_music(@volume) if current_music?
    end

    def play
      LibSDL.mix_volume_music(@volume)
      LibSDL.mix_play_music(data, -1)
      @playing = true
      @@current_music = self
    end

    def rewind
      LibSDL.mix_rewind_music if current_music?
    end

    def stop
      if current_music?
        LibSDL.mix_halt_music
        @playing = false
        @@current_music = nil
      end
    end

    def playing?
      unless current_music?
        @playing = false
      end
      
      @playing
    end

    def pause
      if current_music?
        LibSDL.mix_pause_music
        @playing = false
      end
    end

    def resume
      if current_music?
        LibSDL.mix_volume_music(@volume)
        LibSDL.mix_resume_music
        @playing = true
      end
    end

    def free
      if @data
        LibSDL.mix_free_music(data)
        @data = nil
      end
    end

    def finalize
      free
    end

    def self.load_from_file(filename : String)
      music = Crystal2Day::Music.new
      music.load_from_file!(filename)

      return music
    end

    def load_from_file!(filename : String)
      free 

      @data = LibSDL.mix_load_mus(filename)
      Crystal2Day.error "Could not load music from file #{filename}" unless @data
    end
  end
end
