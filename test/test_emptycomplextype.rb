require 'test/unit'
require 'wsdl/parser'

class TestWSDL < Test::Unit::TestCase
  def self.setup(filename)
    @@filename = filename
  end

  def test_wsdl
    @wsdl = WSDL::Parser.new.parse(File.open(@@filename).read)
  end
end

TestWSDL.setup(ARGV.shift || 'emptycomplextype.wsdl')
