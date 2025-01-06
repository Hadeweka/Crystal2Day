# A sound class, which can be used for short-time sound effects.
# Multiple sounds can be played at the same time when using different channels.
# You can also pitch-shift the sounds. However, you should avoid shifting up.
# Shifting the pitch up might sound artificial due to information loss.

module Crystal2Day
  class Sound
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::MixChunk))
    
    property pitch : Float32 = 1.0
    property channel : Int32 = 0  # NOTE: Change this only before playing the sound!

    @passed_data : Pointer(PassedData) = Pointer(PassedData).null
    @original_length : UInt32 = 0

    class PassedData
      property chunk_ptr : LibSDL::MixChunk*
      property pitch : Float32
      property original_length : UInt32
      property buffer_counter : UInt32 = 0

      def initialize(@chunk_ptr : LibSDL::MixChunk*, @pitch : Float32, @original_length : UInt32)
      end
    end

    def initialize
      
    end

    def play
      # TODO: For now, pitch shifting is not available due to issues with SDL threads

      pause
      LibSDL.mix_play_channel(@channel, data, 0)
    end

    def volume
      LibSDL.mix_volume_chunk(data, -1)
    end

    def volume=(value : Number)
      LibSDL.mix_volume_chunk(data, value)
      volume
    end

    def self.master_volume
      LibSDL.mix_master_volume(-1)
    end
  
    def self.master_volume=(value : Number)
      LibSDL.mix_master_volume(value)
      self.master_volume
    end

    def pause
      LibSDL.mix_halt_channel(@channel)
    end

    def playing?
      LibSDL.mix_playing(@channel) != 0
    end

    def free
      if @data
        LibSDL.mix_free_chunk(data)
        @data = nil
      end
    end

    def finalize
      free
    end

    def self.load_from_file(filename : String)
      sound = Crystal2Day::Sound.new
      sound.load_from_file!(filename)

      return sound
    end

    def load_from_file!(filename : String)
      free 

      full_filename = Crystal2Day.convert_to_absolute_path(filename)

      @data = LibSDL.mix_load_wav(full_filename)
      Crystal2Day.error "Could not load sound from file #{full_filename}" unless @data
      @original_length = data.value.alen
    end
  end
end
