These samples are created by Peter Gardfjäl.  Thanks!

1) Generate the stubs
    ruby wsdl2ruby.rb --wsdl fault.wsdl --type client --type server --force --quiet
2) Start the server:
    ruby AddServer.rb 12345
3) Run the (add) client:
    ruby -d AddClient.rb  http://localhost:12345 101

The "fault" directory contains a service that raises a fault whenever the added number is greater than 100.
The "multifault" sample behaves the same way, but in addition to the AddFault it also raises a NegativeValueFault if the received value is negative.
