# encoding: UTF-8
require 'helper'
require 'testutil'
require 'soap/marshal'
TestUtil.require(File.dirname(__FILE__), 'marshaltestlib')


if RUBY_VERSION > "1.7.0"


module SOAP
module Marshal
class TestMarshal < Test::Unit::TestCase
  include MarshalTestLib

  def encode(o)
    SOAPMarshal.dump(o)
  end

  def decode(s)
    SOAPMarshal.load(s)
  end
end
end
end


end
