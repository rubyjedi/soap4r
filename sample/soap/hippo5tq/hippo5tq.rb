#!/usr/bin/env ruby

require 'soap/driver'

#Server = 'http://www.hippo2000.net/cgi-bin/soap5tq2.cgi'
Server = 'http://www.hippo2000.net/cgi-bin/soap5tq.cgi'
NS = 'urn:Soap5tq'

proxy = ARGV.shift || nil

def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end


drv = SOAP::Driver.new( nil, 'hippo5tq', NS, Server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )

drv.addMethod( 'Init', 'UsrName', 'Passwd' )
  # => [ sSession, sErr ]
drv.addMethod( 'End', 'sSsID' )
  # => void

drv.addMethod( 'GetQuizAll', 'sSsId' )
  # => [ sQuiz0, sOpt00, sOpt01, sOpt02, sOpt03, sOpt04,
  #      ...
  #      sQuiz9, sOpt90, sOpt91, sOpt92, sOpt93, sOpt94 ]
drv.addMethod( 'RepQuizAll', 'sSsID', 'iRes' )
  # => [ iResult, iPoint ]

drv.addMethod( 'GetQuiz', 'sSsID' )
  # => [ sQuiz, sOpt0, sOpt1, sOpt2, sOpt3, sOpt4 ]
drv.addMethod( 'ReqQuiz', 'sSsID', 'iRes' )
  # => [ iResult, iPoint ]

sessionId, errInfo =  drv.Init( 'SOAP4R', '' )

p drv.GetQuizAll( sessionId )
