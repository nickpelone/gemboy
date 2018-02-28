# frozen-string-literal: true
module Gemboy
  class Gamepak
    HEADER_START = 0x100
    HEADER_END = 0x014F

    TITLE_START = 0x134
    OLD_TITLE_END = 0x143
    NEW_TITLE_END = 0x13E

    NEW_LICENSEE_ENABLE_FIELD = 0x14B
    NEW_LICENSEE_ON = 0x33
    NEW_LICENSEE_STR_BEGIN = 0x144
    NEW_LICENSEE_STR_END = 0x145

    SGB_SUPPORT_FIELD = 0x146
    SGB_SUPPORT_ON = 0x03

    CART_TYPE_FIELD = 0x148

    ROM_SIZE_FIELD = 0x148
    RAM_SIZE_FIELD = 0x149

    DESTINATION_CODE_FIELD = 0x14A

    OLD_LICENSEE_FIELD = 0x14B

    HEADER_CHECKSUM_FIELD = 0x14D

    GLOBAL_CHECKSUM_START = 0x14E
    GLOBAL_CHECKSUM_END = 0x14F

    attr_reader :rom
    attr_reader :rom_path
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

      # TODO Translate Licensee code(s) to names
      if @rom[NEW_LICENSEE_ENABLE_FIELD].unpack('C').first == NEW_LICENSEE_ON
        @header[:licensee] = @rom[NEW_LICENSEE_STR_BEGIN..NEW_LICENSEE_STR_END].bytes
        @header[:title] = @rom[TITLE_START..NEW_TITLE_END].bytes.reject{|b| b == 0}.map(&:chr).join
      else
        # Pull from old licensee field
        @header[:licensee] = @rom[OLD_LICENSEE_FIELD].unpack('C').first
        @header[:title] = @rom[TITLE_START..OLD_TITLE_END].bytes.reject{|b| b == 0}.map(&:chr).join
      end

      if @rom[SGB_SUPPORT_FIELD] == SGB_SUPPORT_ON
       @header[:sgb] = true
      else
       @header[:sgb] = false
      end

      @header[:cart_type] = @rom[CART_TYPE_FIELD].unpack('C').first
      @header[:destination] = @rom[DESTINATION_CODE_FIELD].unpack('C').first

      # TODO Pull checksums
      # Should these instead be part of the constructor? Debate is whether to put in @header
      # a valid yes/no or throw execption when invalid
      # ...
      #
      #check_header # calc and compare header checksum
      #check_rom # calc and compare rom checksum
    end
  end
end
