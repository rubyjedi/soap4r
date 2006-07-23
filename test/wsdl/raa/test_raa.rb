require 'test/unit'
require 'soap/wsdlDriver'
require 'RAA.rb'
require 'RAAServant.rb'
require 'RAAService.rb'


module WSDL
module RAA


class TestRAA < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_server
    setup_client
  end

  def setup_server
    @server = RAABaseServicePortTypeApp.new('RAA server', nil, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      Thread.current.abort_on_exception = true
      @server.start
    }
  end

  def setup_client
    wsdl = File.join(DIR, 'raa.wsdl')
    @raa = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @raa.endpoint_url = "http://localhost:#{Port}/"
  end

  def teardown
    teardown_server
    teardown_client
  end

  def teardown_server
    @server.shutdown
    @t.kill
    @t.join
  end

  def teardown_client
    @raa.reset_stream
  end

  def test_raa
    assert_equal(["ruby", "soap4r"], @raa.getAllListings)

    info = @raa.getInfoFromName("SOAP4R")
    assert_equal(::Info, info.class)
    assert_equal(::Category, info.category.class)
    assert_equal(::Product, info.product.class)
    assert_equal(::Owner, info.owner.class)
    assert_equal("major", info.category.major)
    assert_equal("minor", info.category.minor)
    assert_equal(123, info.product.id)
    assert_equal("SOAP4R", info.product.name)
    assert_equal("short description", info.product.short_description)
    assert_equal("version", info.product.version)
    assert_equal("status", info.product.status)
    assert_equal("http://example.com/homepage", info.product.homepage.to_s)
    assert_equal("http://example.com/download", info.product.download.to_s)
    assert_equal("license", info.product.license)
    assert_equal("description", info.product.description)
    assert_equal(456, info.owner.id)
    assert_equal("mailto:email@example.com", info.owner.email.to_s)
    assert_equal("name", info.owner.name)
    assert(!info.created.nil?)
    assert(!info.updated.nil?)
  end

  def foo
    p @raa.getInfoFromCategory(Category.new("Library", "XML"))
    t = Time.at(Time.now.to_i - 24 * 3600)
    p @raa.getModifiedInfoSince(t)
    p @raa.getModifiedInfoSince(DateTime.new(t.year, t.mon, t.mday, t.hour, t.min, t.sec))
    p o.type
    p o.owner.name
    p o
  end
end


end
end
