#!/usr/bin/env ruby -Ke


# RNNのSOAPサービスを利用するサンプルです。テスト記事に対するコメントを
# 投稿します。実行する前に、
# http://cvs.sourceforge.jp/cgi-bin/viewcvs.cgi/*checkout*/rnn/rnn/doc/articles/xmlrpc.txt
# および
# http://rwiki.jin.gr.jp/cgi-bin/rw-cgi.rb?cmd=view;name=RNN%A4%C8SOAP4R%A4%C7%CD%B7%A4%DC%A4%A6
# を参照してください。


require 'soap/wsdlDriver'
wsdl = 'http://cvs.sourceforge.jp/cgi-bin/viewcvs.cgi/*checkout*/rnn/rnn/app/rnn-hash.wsdl'
rnn = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
rnn.generate_explicit_type = true
rnn.wiredump_dev = STDERR


test_article_id = 1
POST_COMMENT_DIRECT = 0

subject = "SOAP4Rによるテスト by NaHiの名無しさん"
text =<<__EOS__
euc-jpでのテスト投稿です。
__EOS__

p rnn.post_comment(test_article_id, POST_COMMENT_DIRECT, subject, text)
