# frozen_string_literal: true

class Album
  attr_accessor :songs, :best_song

  def initialize(songs = nil, best_song = nil)
    @songs      = songs
    @best_song  = best_song
  end

  def ==(other)
    songs == other.songs and best_song == other.best_song
  end
end
