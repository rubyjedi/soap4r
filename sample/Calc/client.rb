require 'soap/driver'

server = 'http://localhost:7000/'

calc = SOAP::Driver.new( nil, nil, 'http://tempuri.org/calcService', server )
calc.addMethod( 'add', 'lhs', 'rhs' )
calc.addMethod( 'sub', 'lhs', 'rhs' )
calc.addMethod( 'multi', 'lhs', 'rhs' )
calc.addMethod( 'div', 'lhs', 'rhs' )

puts 'add: 1 + 2	# => 3'
puts calc.add( 1, 2 )
puts 'sub: 1.1 - 2.2	# => -1.1'
puts calc.sub( 1.1, 2.2 )
puts 'multi: 1.1 * 2.2	# => 2.42'
puts calc.multi( 1.1, 2.2 )
puts 'div: 5 / 2	# => 2'
puts calc.div( 5, 2 )
puts 'div: 5.0 / 2	# => 2.5'
puts calc.div( 5.0, 2 )
puts 'div: 1.1 / 0	# => Infinity'
puts calc.div( 1.1, 0 )
puts 'div: 1 / 0	# => ZeroDivisionError'
puts calc.div( 1, 0 )
