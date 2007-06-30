require 'soap/rpc/driver'
require 'soap/filter/streamhandler'

server = ARGV.shift || 'http://localhost:7000/'

class CookieFilter < SOAP::Filter::StreamHandler
  attr_accessor :cookie_value

  def initialize
    @cookie_value = nil
  end

  def on_http_outbound(req)
    req.header['Cookie'] = @cookie_value if @cookie_value
  end

  def on_http_inbound(req, res)
    # this sample filter only caputures the first cookie.
    cookie = res.header['Set-Cookie'][0]
    cookie.sub!(/;.*\z/, '') if cookie
    @cookie_value = cookie
    # do not save cookie value.
    puts "new cookie value: #{@cookie_value}"
  end
end

var = SOAP::RPC::Driver.new( server, 'http://tempuri.org/calcService' )
var.add_method( 'set', 'newValue' )
var.add_method( 'get' )
var.add_method_as( '+', 'add', 'rhs' )
var.add_method_as( '-', 'sub', 'rhs' )
var.add_method_as( '*', 'multi', 'rhs' )
var.add_method_as( '/', 'div', 'rhs' )
var.streamhandler.filterchain << CookieFilter.new
var.wiredump_dev = STDOUT if $DEBUG

puts 'var.set( 1 )'
puts '# Bare in mind that another client set another value to this service.'
puts '# This is only a sample for proof of concept.'
var.set( 1 )
puts 'var + 2	# => 1 + 2 = 3'
puts var + 2
puts 'var - 2.2	# => 1 - 2.2 = -1.2'
puts var - 2.2
puts 'var * 2.2	# => 1 * 2.2 = 2.2'
puts var * 2.2
puts 'var / 2	# => 1 / 2 = 0'
puts var / 2
puts 'var / 2.0	# => 1 / 2.0 = 0.5'
puts var / 2.0
puts 'var / 0	# => 1 / 0 => ZeroDivisionError'
puts var / 0
