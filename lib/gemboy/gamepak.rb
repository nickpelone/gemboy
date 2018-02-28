# frozen-string-literal: true
module Gemboy
  class Gamepak
    attr_reader :header

    def initialize(path)
      # TODO all the fancy File.whatever methods to do relative paths and things
      @rom_path = path
      @rom = File.read(@rom_path, mode: 'rb')

      parse_header
    end

    # Prevent printing the whole dang ROM to stdout during irb sessions
    def inspect
      "#<#{self.class.name} ROM: #{@rom_path}>"
    end

    private
    def parse_header
      @header = Hash.new
    end
  end
end
