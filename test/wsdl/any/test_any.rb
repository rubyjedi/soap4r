require 'test/unit'
require 'wsdl/parser'
module WSDL; module Any


class TestAny < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))
  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_any
    system("cd #{DIR} && ruby #{pathname("../../../bin/wsdl2ruby.rb")} --classdef --wsdl #{pathname("any.wsdl")} --type client --type server --force")
    compare("expectedDriver.rb", "echoDriver.rb")
    compare("expectedEcho.rb", "echo.rb")
    compare("expectedService.rb", "echo_service.rb")

    File.unlink(pathname("echo_service.rb"))
    File.unlink(pathname("echo.rb"))
    File.unlink(pathname("echo_serviceClient.rb"))
    File.unlink(pathname("echoDriver.rb"))
    File.unlink(pathname("echoServant.rb"))
  end

  def compare(expected, actual)
    assert_equal(loadfile(expected), loadfile(actual))
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end
