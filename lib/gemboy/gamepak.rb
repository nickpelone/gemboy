# frozen-string-literal: true
module Gemboy
  class Gamepak
    attr_reader :header

    def initialize(path)
      # TODO all the fancy File.whatever methods to do relative paths and things
      @rom = File.read(path, mode: 'rb')

      parse_header
    end

    private
    def parse_header
      @header = Hash.new
    end
  end
end
