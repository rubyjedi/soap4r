require 'test/unit'
require 'wsdl/parser'
module WSDL; module SimpleType


class TestRPC < Test::Unit::TestCase
  def pathname(filename)
    File.join(File.dirname(File.expand_path(__FILE__)), filename)
  end

  def test_any
    system("ruby #{pathname("../../../bin/wsdl2ruby.rb")} --classdef --wsdl #{pathname("any.wsdl")} --type client --type server --force")
    compare("expectedDriver.rb", "echoDriver.rb")
    compare("expectedEcho.rb", "echo.rb")
    compare("expectedService.rb", "echo_service.rb")

    File.unlink("echo_service.rb")
    File.unlink("echo.rb")
    File.unlink("echo_serviceClient.rb")
    File.unlink("echoDriver.rb")
    File.unlink("echoServant.rb")
  end

  def compare(expected, actual)
    assert_equal(loadfile(expected), loadfile(actual))
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end
