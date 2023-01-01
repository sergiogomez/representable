# frozen_string_literal: true

class Song
  attr_accessor :name, :track # never change this, track rendered with Rails#to_json.

  def initialize(name = nil, track = nil)
    @name   = name
    @track  = track
  end

  def ==(other)
    name == other.name and track == other.track
  end
end
