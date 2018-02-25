# frozen-string-literal: true
RSpec.describe Gemboy::Gamepak do
  it "can parse a header" do
    # Get a ROM from the roms/ folder
    roms_pathname = Pathname.new("roms/")
    rom_to_load = Dir.new(roms_pathname.realpath.to_path).entries.select{|r| r.match(/\.gb$/)}.first
    rom_path = "#{roms_pathname.to_path}/#{rom_to_load}"

    # Load the ROM
    gamepak = Gemboy::Gamepak.new(rom_path)

    # Test that the header parsed
    expect(gamepak.header).to_not be_empty
  end 
end
