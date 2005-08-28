#!/usr/bin/env ruby


# RNNのSOAPサービスを利用するサンプルです。詳細については、
# http://cvs.sourceforge.jp/cgi-bin/viewcvs.cgi/*checkout*/rnn/rnn/doc/articles/xmlrpc.txt
# および
# http://rwiki.jin.gr.jp/cgi-bin/rw-cgi.rb?cmd=view;name=RNN%A4%C8SOAP4R%A4%C7%CD%B7%A4%DC%A4%A6
# を参照してください。


require 'soap/wsdlDriver'
#wsdl = 'http://cvs.sourceforge.jp/cgi-bin/viewcvs.cgi/*checkout*/rnn/rnn/app/rnn-hash.wsdl'
wsdl = 'rnn-hash.wsdl'
rnn = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
rnn.generate_explicit_type = true
rnn.wiredump_dev = STDOUT

test_article_id = 1
POST_COMMENT_DIRECT = 0


# 日付で新しい順にソートして，pos番目からn個のニュースを取り出します
pos = 0
n = 5
topicid = nil
puts rnn.list(pos, n, topicid)
exit

# IDが id の記事を取得します
rnn.article(test_article_id).each do |k, v|
  puts "#{k}: #{v}"
end

# IDが id の記事についてのすべてのコメントを取得します
puts rnn.comments(test_article_id)

# 最近 days 日間の記事を取得します
days = 1
topic = nil
rnn.recent_articles(days, topic).each do |article|
  article.each do |k, v|
    puts "#{k}: #{v}"
  end
end

# 最近 days 日間のコメントを取得します
days = 1
rnn.recent_comments(days).each do |comment|
  comment.each do |k, v|
    puts "#{k}: #{v}"
  end
end

# トピックの分類一覧を取得します
rnn.topics.each do |topic|
  topic.each do |k, v|
    puts "#{k}: #{v}"
  end
end
