require 'soap/rpc/driver'
#GC.start
server = 'http://localhost:7000/'
# server = 'http://localhost/cgi-bin/server2.cgi'

var = SOAP::RPC::Driver.new( server, 'http://tempuri.org/calcService' )
var.addMethod( 'set', 'newValue' )
var.addMethod( 'get' )
var.addMethodAs( '+', 'add', 'rhs' )
var.addMethodAs( '-', 'sub', 'rhs' )
var.addMethodAs( '*', 'multi', 'rhs' )
var.addMethodAs( '/', 'div', 'rhs' )

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
