require 'test/unit'
require 'wsdl/parser'
module WSDL; module SOAP; module WSDL2Ruby


class TestWSDL2Ruby < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    system("cd #{DIR} && ruby #{pathname("../../../../bin/wsdl2ruby.rb")} --wsdl #{pathname("rpc.wsdl")} --classdef --client_skelton --servant_skelton --cgi_stub --standalone_server_stub --driver --force --quiet")
  end

  def teardown
    # leave generated file for debug.
  end

  def test_rpc
    compare("expectedServant.rb", "echo_versionServant.rb")
    compare("expectedClassdef.rb", "echo_version.rb")
    compare("expectedService.rb", "echo_version_service.rb")
    compare("expectedService.cgi", "echo_version_service.cgi")
    compare("expectedDriver.rb", "echo_versionDriver.rb")
    compare("expectedClient.rb", "echo_version_serviceClient.rb")

    File.unlink(pathname("echo_versionServant.rb"))
    File.unlink(pathname("echo_version.rb"))
    File.unlink(pathname("echo_version_service.rb"))
    File.unlink(pathname("echo_version_service.cgi"))
    File.unlink(pathname("echo_versionDriver.rb"))
    File.unlink(pathname("echo_version_serviceClient.rb"))
  end

private

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    assert_equal(loadfile(expected), loadfile(actual))
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end
end


end; end; end
