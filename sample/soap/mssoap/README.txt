these samples are from an 'anonymous contributor from Wall St'.  Thanks!

= MANIFEST =

stockQuoteService.wsdl ..... A getQuote sample service definition.

stockQuoteService.rb ....... getQuote sample service which returns random value
stockQuoteService.cgi ...... CGI interface of stockQuoteService

stockQuoteServicePortTypeDriver.rb ... soap4r client stub for the service
stockQuoteServiceClient.rb ........... soap4r client which uses the stub
client.vba ........................... A VBA sample to access the service
stockQuoteServiceClient.xls .......... An excel client contains the VBA sample


= How to run =

1. server setup

  1. setup CGI enabled Web server such as apache httpd.

  2. copy following 3 files to cgi-bin directory at the server.

      stockQuoteService.wsdl
      stockQuoteService.rb
      stockQuoteService.cgi

  3. configure the URL at the bottom of stockQuoteService.wsdl to point the URL
    of the CGI interface.

      ex. http://localhost/cgi-bin/stockQuoteService.cgi
        -> http://localhost/~myname/testcgi/stockQuoteService.cgi

  4. change "#!/usr/bin/env ruby" at the head of the CGI interface to point a
    ruby interpreter you have.

      ex. #!/usr/bin/env ruby
        -> #!/usr/local/bin/ruby

2. client usage

  1. soap4r sample

    run stockQuoteServiceClient.rb with WSDL location.

      ex. $ ruby stockQuoteServiceClient.rb http://localhost/~myname/testcgi/stockQuoteService.cgi

  2. VBA sample

    open stockQuoteServiceClient.xls with Excel.  You need to configure the
    accessing URL in VBA macro.


= FYI =

These files are generated wsdl2ruby.rb then are modified.
  stockQuoteService.rb
  stockQuoteService.cgi
  stockQuoteServicePortTypeDriver.rb
  stockQuoteServiceClient.rb

$ wsdl2ruby.rb --wsdl stockQuoteService.wsdl --type client --cgi_stub --servant_skelton
