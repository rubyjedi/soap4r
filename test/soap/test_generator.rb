# encoding: ASCII-8BIT
require 'helper'
require 'soap/processor'


module SOAP


class TestGenerator < Test::Unit::TestCase
  # based on #417, reported by Kou.
  def test_encode
    str = "\343\201\217<"
    g = SOAP::Generator.new
    g.generate(SOAPElement.new('foo'))
    assert_equal("&lt;", g.encode_string(str)[-4, 4])
    #
    if RUBY_VERSION.to_f >= 1.9
      assert_equal("&lt;", g.encode_string(str)[-4, 4])
    else
      begin
        kc_backup = $KCODE.dup
        $KCODE = 'EUC-JP'
        assert_equal("&lt;", g.encode_string(str)[-4, 4])
      ensure
        $KCODE = kc_backup
      end
    end
  end
end


end
