# encoding: UTF-8
require 'helper'
require 'soap/rpc/driver'
require 'logger'
require 'webrick'
require 'rbconfig'


module SOAP
module Calc


class TestCalcCGI < Test::Unit::TestCase
  # This test shuld be run after installing ruby.
  RUBYBIN = File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]
  )
  RUBYBIN << " -d" if $DEBUG

  if RUBY_VERSION.to_f >= 2.2
    logger_gem = Gem::Specification.find { |s| s.name == 'logger-application' }
    if logger_gem
      paths = logger_gem.respond_to?(:full_require_paths) ? logger_gem.full_require_paths : logger_gem.load_paths
      paths.each do |path|
        RUBYBIN << " -I #{path}"
      end
    end
  end

  Port = 17171

  def setup
    logger = Logger.new(STDERR)
    logger.level = Logger::Severity::ERROR
    @server = TestUtil.webrick_http_server(
      :BindAddress => "0.0.0.0",
      :Logger => logger,
      :Port => Port,
      :AccessLog => [],
      :DocumentRoot => File.dirname(File.expand_path(__FILE__)),
      :CGIPathEnv => ENV['PATH'],
      :CGIInterpreter => RUBYBIN
    )
    @t = TestUtil.start_server_thread(@server)
    @endpoint = "http://localhost:#{Port}/server.cgi"
    @calc = SOAP::RPC::Driver.new(@endpoint, 'http://tempuri.org/calcService')
    @calc.wiredump_dev = STDERR if $DEBUG
    @calc.add_method('add', 'lhs', 'rhs')
    @calc.add_method('sub', 'lhs', 'rhs')
    @calc.add_method('multi', 'lhs', 'rhs')
    @calc.add_method('div', 'lhs', 'rhs')
  end

  def teardown
    @server.shutdown if @server
    if @t
      @t.kill
      @t.join
    end
    @calc.reset_stream if @calc
  end

  def test_calc_cgi
    assert_equal(3, @calc.add(1, 2))
    assert_equal(-1.1, @calc.sub(1.1, 2.2))
    assert_equal(2.42, @calc.multi(1.1, 2.2))
    assert_equal(2, @calc.div(5, 2))
    assert_equal(2.5, @calc.div(5.0, 2))
    assert_equal(1.0/0.0, @calc.div(1.1, 0))
    assert_raises(ZeroDivisionError) do
      @calc.div(1, 0)
    end
  end
end


end
end
