require 'soap/driver'
require 'devel/logger'

require 'iSampleStruct'

#server = 'http://rrr.jin.gr.jp/soapsrv'
server = 'http://localhost:10080/soapsrv'

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
