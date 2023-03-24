module Crystal2Day
  class Sound
    Crystal2DayHelper.wrap_type(Pointer(LibSDL::MixChunk))
    
    property pitch : Float32 = 1.0
    property channel : Int32 = 0

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
      @passed_data = Pointer.malloc(size: 1, value: PassedData.new(data, @pitch, @original_length))

      # NOTE: This is very hacky, but it's better than nothing
      # Before each playing, the length of the sound is adjusted to match the current pitch
      # The old length is still stored in this class, so it is not lost

      corrected_length = (4.0 * @original_length / pitch).ceil.to_i // 4
      data.value.alen = corrected_length

      # A callback is created, which will be called by the sound playing thread every now and then
      # The arguments we want to pass to the callback are all in the PassedData struct
      # The callback then modifies the current buffer accordingly
      # However, we need some minor tricks, since the buffer is only a part of the whole sound data

      pitch_callback = LibSDL::MixEffectFuncT.new do |channel, stream, length, arg|

        # NOTE: Audio format here is AUDIO_S16LSB by Crystal2Day initialization

        received_data = arg.as(Pointer(PassedData))
        data_stream = stream.as(Pointer(Int8))

        orig_stream = received_data.value.chunk_ptr.value.abuf.as(Pointer(Int8))

        # Now, we iterate over each sample (2 bytes per sample, and 2 channels)

        0.upto(length // 4 - 1) do |i|

          # We just need a pitch-modified index, the rest is trivial
          # However, it still needs to be a multiple of 4

          orig_index = received_data.value.buffer_counter + 4 * i
          modified_index = (received_data.value.pitch * orig_index).to_i
          modified_index -= modified_index % 4

          # We need a safeguard to ensure we do not read any invalid data

          if modified_index < received_data.value.chunk_ptr.value.alen

            # Left channel processing

            data_stream[4 * i + 0] = orig_stream[modified_index + 0]
            data_stream[4 * i + 1] = orig_stream[modified_index + 1]

            # Right channel processing

            data_stream[4 * i + 2] = orig_stream[modified_index + 2]
            data_stream[4 * i + 3] = orig_stream[modified_index + 3]
          else

            # If we somehow go too far, just zero out the buffer data
            # Then, the sound simply goes silent

            data_stream[4 * i + 0] = 0
            data_stream[4 * i + 1] = 0
            data_stream[4 * i + 2] = 0
            data_stream[4 * i + 3] = 0
          end
        end

        # In the end, update our buffer counter to match our progress

        received_data.value.buffer_counter += length
      end

      LibSDL.mix_halt_channel(@channel)
      LibSDL.mix_register_effect(@channel, pitch_callback, nil, @passed_data.as(Pointer(Void)))
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

      @data = LibSDL.mix_load_wav(filename)
      Crystal2Day.error "Could not load sound from file #{filename}" unless @data
      @original_length = data.value.alen
    end
  end
end
