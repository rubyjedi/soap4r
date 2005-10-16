require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
module WSDL; module SOAP


class TestWSDL2Ruby < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      gen = WSDL::SOAP::WSDL2Ruby.new
      gen.location = pathname("rpc.wsdl")
      gen.basedir = DIR
      gen.logger.level = Logger::FATAL
      gen.opt['classdef'] = nil
      gen.opt['client_skelton'] = nil
      gen.opt['servant_skelton'] = nil
      gen.opt['cgi_stub'] = nil
      gen.opt['standalone_server_stub'] = nil
      gen.opt['driver'] = nil
      gen.opt['force'] = true
      silent do
        gen.run
      end
    ensure
      Dir.chdir(backupdir)
    end
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
    begin
      assert_equal(loadfile(expected), loadfile(actual), expected)
    rescue
      puts `diff -U 2 -p #{expected} #{actual}`
      raise
    end
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end

  def silent
    back = $VERBOSE
    $VERBOSE = nil
    begin
      yield
    ensure
      $VERBOSE = back
    end
  end
end


end; end
