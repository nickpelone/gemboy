# frozen_string_literal: true

module Gemboy
  # Represents a Gamepak for reading header and ROM data from.
  class Gamepak
    HEADER_START = 0x100
    HEADER_END = 0x014F

    CHKSUM_HEADER_START = 0x134
    CHKSUM_HEADER_END = 0x14C
    CHKSUM_HEADER_FIELD = 0x14D

    CHKSUM_GLOBAL_START = 0x14E

    TITLE_START = 0x134
    OLD_TITLE_END = 0x143
    NEW_TITLE_END = 0x13E

    CGB_SUPPORT_FIELD = 0x143 # On newer carts this is not in the title
    CGB_SUPPORTED = 0x80
    CGB_ONLY = 0xC0

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
      # TODO: all the fancy File.whatever methods to do relative paths and things
      @rom_path = path
      @rom = File.read(@rom_path, mode: 'rb')

      parse_header
    end

    # Prevent printing the whole dang ROM to stdout during irb sessions
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} Game: #{@header[:title]} Header: #{header_valid? ? 'OK' : 'INVALID'} ROM: #{rom_valid? ? 'OK' : 'INVALID'}>"
    end

    def valid?
      header_valid? && rom_valid?
    end

    def header_valid?
      @header[:header_valid]
    end

    def rom_valid?
      @header[:rom_valid]
    end

    private

    def parse_header
      @header = {}

      # TODO: Translate Licensee code(s) to names
      if @rom[NEW_LICENSEE_ENABLE_FIELD].bytes.first == NEW_LICENSEE_ON
        @header[:licensee] = @rom[NEW_LICENSEE_STR_BEGIN..NEW_LICENSEE_STR_END].bytes.map(&:chr).join.to_i(16)
        @header[:title] = @rom[TITLE_START..NEW_TITLE_END].bytes.reject(&:zero?).map(&:chr).join
      else
        # Pull from old licensee field
        @header[:title] = @rom[TITLE_START..OLD_TITLE_END].bytes.reject(&:zero?).map(&:chr).join
        @header[:licensee] = @rom[OLD_LICENSEE_FIELD].bytes.first
      end

      @header[:sgb_support] = (@rom[SGB_SUPPORT_FIELD].bytes.first == SGB_SUPPORT_ON)

      # Platform detection
      @header[:platform] = if @rom[CGB_SUPPORT_FIELD].bytes.first == CGB_SUPPORTED || @rom[CGB_SUPPORT_FIELD].bytes.first == CGB_ONLY
        'Game Boy Color' # rubocop:disable Layout/IndentationWidth
      elsif @rom[SGB_SUPPORT_FIELD].bytes.first == SGB_SUPPORT_ON # rubocop:disable Layout/ElseAlignment
        'Super Game Boy'
      else # rubocop:disable Layout/ElseAlignment
        'Game Boy'
      end # rubocop:disable Layout/EndAlignment

      @header[:cart_type] = @rom[CART_TYPE_FIELD].bytes.first
      @header[:destination] = @rom[DESTINATION_CODE_FIELD].bytes.first

      @header[:header_checksum] = checksum_header
      @header[:header_valid] = (@header[:header_checksum] == @rom[CHKSUM_HEADER_FIELD].bytes.first)

      @header[:global_checksum] = checksum_rom
      @header[:rom_valid] = (@header[:global_checksum] == @rom.slice(CHKSUM_GLOBAL_START, 2).bytes)
    end

    def checksum_header
      header = @rom[CHKSUM_HEADER_START..CHKSUM_HEADER_END]
      (0 - header.bytes.reduce(0) { |memo, i| memo + i } - 25) & 255
    end

    def checksum_rom
      sum = 0
      @rom.bytes.each_with_index do |b, i|
        sum += b unless [0x14E, 0x14F].include? i
      end
      [sum].pack('n').bytes # Take the two lower bytes of the result
    end
  end
end
