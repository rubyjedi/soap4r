require 'soap/wsdlDriver'
wsdl = 'http://cvs.sourceforge.jp/cgi-bin/viewcvs.cgi/*checkout*/rnn/rnn/app/rnn-hash.wsdl'
rnn = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
rnn.generate_explicit_type = true
rnn.wiredump_dev = STDOUT

topic_map = {}
rnn.topics.each do |topic|
  topic_id = topic['topic_id']
  topic['children'] = {}
  topic_map[topic_id] = topic
end

topic_tree = {}
topic_map.each do |id, topic|
  topic_pid = topic['topic_pid']
  topic_title = topic['topic_title']
  if topic_pid.zero?
    topic_tree[topic_title] = topic
  else
    topic_map[topic_pid]['children'][topic_title] = topic
  end
end

topic_id = topic_tree['ライブラリ']['children']['XML']['topic_id']

title = "soap4r/1.4.8.1がりリースされた"
text =<<'__EOS__'
soap4r/1.4.8.1がリリースされた。

1.4.7からの変更点は以下の通り。
* Ruby/1.8利用時に発生するwarningが出ないようにしました。
* WSDLを読み、クライアントから簡単にメソッドを呼び出せるようにする
  wsdlDriverを追加しました。Googleを検索するサンプル。 
    require 'soap/wsdlDriver'
    searchWord = ARGV.shift
    # http://www.google.com/apis/からライセンスキーを取得する必要があります。
    key = File.open(File.expand_path("~/.google_key")).read.chomp
    GOOGLE_WSDL = 'http://api.google.com/GoogleSearch.wsdl'
    # Load WSDL and create driver.
    google = SOAP::WSDLDriverFactory.new(GOOGLE_WSDL).create_rpc_driver
    # Just invoke!
    result = google.doGoogleSearch(key, searchWord, 0, 10, false, "", false, "", 'utf-8', 'utf-8')
    result.resultElements.each do |ele|
      puts "== #{ele.title}: #{ele.URL}"
      puts ele.snippet
      puts
    end
  サンプルとして、AmazonWebServices、RAA、RNNのwsdlDriver利用プログラムも
  sampleディレクトリに置いてあります。
* xmlscanのサポート。
* XML processorの検出手順を変更。xmlscan、REXML、XMLParser、NQXMLの順に
  検索します。
* 漢字コードハンドリングを修正。euc-jpもしくはshift_jisを使うためには、
  xmlscan-0.2を使えばuconvモジュールがなくてもかまいません。その他のXML
  processorを使う場合はuconvモジュールが必要です。
* cgistub.rb: SOAPレスポンスのメディアタイプを変更できるようにした。
  ケータイJavaで、text/xmlを食わないやつがいた。。。
* wsdl2ruby: --forceオプションを追加しました。
* たくさんのバグ修正。
__EOS__

p rnn.submit(title, text, topic_id)
