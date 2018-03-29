# frozen-string-literal: true
module Gemboy
  module Instructions
    OPCODES = {
      0x00 => {
        method: :nop
      },
      # 8-bit loads

      # TODO LD nn,n
      # (opcodes 06, 0E, 16, 1E, 26, 2E)

      0x7F => {
        method: :ld_r1_r2
        params: [:@a, :@a],
        mtime: 1
      },

      0x078 => {
        method: :ld_r1_r2,
        params: [:@a, :@b],
        mtime: 1
      },

      0x79 => {
        method: :ld_r1_r2,
        params: [:@a, :@c],
        mtime: 1
      },

      0x7A => {
        method: :ld_r1_r2,
        params: [:@a, :@d],
        mtime: 1
      },

      0x7B => {
        method: :ld_r1_r2,
        params: [:@a, :@e],
        mtime: 1
      }
    }
    # opcode 00
    def nop
      set_clocks
    end

    private
    # Set the clock registers based on how much m-time
    # an instruction is meant to take.
    def set_clocks(mtime=1)
      @m = mtime
      @t = 4*mtime
      nil
    end
  end
end
