require 'test/unit'
require 'soap/mapping'
require 'soap/processor'
require 'soap/rpc/element'


module SOAP
module Marshal


class TestDefinedArray < Test::Unit::TestCase
  def pathname(filename)
    File.join(File.dirname(__FILE__), filename)
  end

  def setup
    back = $:.dup
    begin
      $:.unshift(pathname('.'))
      require pathname('amazonEcDriver')
    ensure
      $:.replace(back)
    end
  end

  def test_amazonresponse
    drv = AWSECommerceServicePortType.new
    drv.test_loopback_response << File.read(pathname('amazonresponse.xml'))
    obj = drv.itemSearch(ItemSearch.new)
    assert_equal(3, obj.items[0].item[0].tracks.size)
  end
end


end
end
