require 'soap/driver'
require 'devel/logger'

require 'iSampleStruct'

# server = 'http://rrr.jin.gr.jp/soapsrv'
server = 'http://localhost:2000/soapsrv'

logger = Devel::Logger.new( STDERR )
drv = SOAP::Driver.new( logger, $0, SampleStructServiceNamespace, server )
drv.addMethod( 'hi', 'sampleStruct' )

p drv.hi( SampleStruct.new )
