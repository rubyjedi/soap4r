#!/usr/bin/env ruby

$KCODE = 'SJIS'

proxy = ARGV.shift || nil

require 'soap/driver'

# XML Schema Datatypesの1999版を指定（はよなくなってくれ）
require 'soap/XMLSchemaDatatypes1999'

# Wiredumpの出力先
def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end

# サービス情報の登録（本来ならWSDLから作られるべきところ）
Server = 'http://www.hippo2000.net/cgi-bin/soap5tq2.cgi'
NS = 'urn:Soap5tq2'

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


# クイズサービスへのログイン
sessionId, errInfo =  drv.Init( 'SOAP4R', '' )

totalPoint = 0

# 中断時。。。
trap( "INT" ) do | sig |
  puts "中断されました"
  drv.End( sessionId )
  exit( -1 )
end

# 最初に一括してクイズを取得してしまう
quizAll = drv.GetQuizAll( sessionId )

# 小細工メソッドを仕込む
def quizAll.next
  quiz, opt1, opt2, opt3, opt4, opt5 = self.slice!( 0..5 )
  return quiz, opt1, opt2, opt3, opt4, opt5
end

def quizAll.eof?
  ( self.length < 6 )
end

# クイズ開始

# クイズの残ってる間。。。
while !quizAll.eof?
  quiz, *opt = quizAll.next

  # 出題
  puts '-' * 78
  puts quiz
  1.upto( opt.length ) do | i |
    puts "#{ i }: #{ opt[ i-1 ] }"
  end

  # 回答
  ans = gets.chomp.to_i

  # 回答を照合する
  result, point = drv.RepQuizAll( sessionId, ans - 1 )

  # 判定結果は?
  unless result.zero?
    puts "正解 得点: #{ point }"
    totalPoint += point
  else
    puts "ハズレ"
  end
end

puts "Total: #{ totalPoint }"

# ログオフ
drv.End( sessionId )
