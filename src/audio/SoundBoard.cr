module Crystal2Day
  class SoundBoard
    @channels = Array(Sound?).new(size: 8) {nil}

    def play_sound(filename : String, channel : Int = 0, volume : Float = 1.0, pitch : Float = 1.0)
      check_channel(channel)
      sound = Crystal2Day.rm.load_sound(filename, channel.to_s) # Cache equal sounds separately for each channel
      sound.channel = channel.to_i32
      sound.volume = SoundBoard.convert_float_volume(volume)
      sound.pitch = pitch.to_f32

      @channels[channel] = sound
      sound.play
    end

    def pause_sound(channel : Int = 0)
      check_channel(channel)
      @channels[channel].not_nil!.pause if @channels[channel]?
    end

    def sound_playing?(channel : Int = 0)
      check_channel(channel)
      if @channels[channel]?
        @channels[channel].not_nil!.playing?
      else
        false
      end
    end

    def check_channel(channel : Int)
      if channel > 7 || channel < -1
        Crystal2Day.error "Sound channel #{channel} is invalid. Use channels 0 to 7 instead (or -1 for all channels)."
      end
    end

    def self.convert_float_volume(volume : Float)
      return (volume * Crystal2Day::MAX_VOLUME).to_i.clamp(0, Crystal2Day::MAX_VOLUME)
    end

    def play_music(filename : String, volume : Float = 1.0)
      music = Crystal2Day.rm.load_music(filename)
      music.volume = SoundBoard.convert_float_volume(volume)
      music.play
    end

    def pause_music
      if Crystal2Day::Music.current_music
        Crystal2Day::Music.current_music.not_nil!.pause
      end
    end

    def resume_music
      if Crystal2Day::Music.current_music
        Crystal2Day::Music.current_music.not_nil!.resume
      end
    end

    def stop_music
      if Crystal2Day::Music.current_music
        Crystal2Day::Music.current_music.not_nil!.stop
      end
    end
  end

  def music_playing?
    if Crystal2Day::Music.current_music
      Crystal2Day::Music.current_music.not_nil!.playing?
    else
      false
    end
  end
end
