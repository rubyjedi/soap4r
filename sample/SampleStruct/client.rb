require 'soap/driver'
require 'devel/logger'

require 'iSampleStruct'

server = 'http://localhost:7000/'

logger = nil
wireDumpDev = nil
# logger = Devel::Logger.new( STDERR )
# wireDumpDev = STDERR

drv = SOAP::Driver.new( logger, $0, SampleStructServiceNamespace, server )
drv.setWireDumpDev( wireDumpDev )

drv.addMethod( 'hi', 'sampleStruct' )

o1 = SampleStruct.new
puts "Sending struct: #{ o1.inspect }"
puts
o2 = drv.hi( o1 )
puts "Received (wrapped): #{ o2.inspect }"
