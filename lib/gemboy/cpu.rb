# frozen-string-literal: true
module Gemboy
  class CPU
    include Instructions

    attr_accessor :a
    attr_accessor :b
    attr_accessor :c
    attr_accessor :d
    attr_accessor :e
    attr_accessor :h
    attr_accessor :l

    attr_accessor :sp
    attr_accessor :pc

    attr_accessor :ram

    attr_reader :pak

    RAM_SIZE = 65536

    def initialize(rom)
      @a = 0
      @b = 0
      @c = 0
      @d = 0
      @e = 0
      @h = 0
      @l = 0

      @sp = 0
      @pc = 0

      @pak = Gemboy::Gamepak.new(rom)

      # Clocks for last instruction
      @m = 0
      @t = 0             

      # TODO MMU

#     zero_ram
#     load_rom
#     enter_rom
#     emu_loop
    end

    def zero_ram
      for i in 0...RAM_SIZE do
        @ram[i] = "\x00"
      end
    end

    def load_rom
      @ram[(0x100)..(0x7FFF)] = @pak.rom 
    end

    def enter_rom
      @pc = 0x150
    end

    def emu_loop
      loop do
        insn = decode(@ram[@pc])
        send(insn)
        @pc+= 1
      end
    end

    def decode(byte)
      opcode = byte.unpack('C')
      raise StandardError, "No instructions are implemented (0x#{opcode.to_s(16)})"
    end

    def af
    end

    def af=(val)
    end

    def bc
    end

    def bc=(val)
    end

    def de
    end

    def de=(val)
    end

    def hl
    end

    def hl=
    end

    def sp
    end

    def sp=
    end

    def pc
    end

    def pc=
    end

    private
  end
end
