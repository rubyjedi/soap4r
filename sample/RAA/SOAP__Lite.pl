# RAA SOAP interface client sample; Perl version.
# 2001-03-28T21:00 Kawai,Takanori [GCD00051@nifty.ne.jp]
# 
# You need to download and install SOAP::Lite for Perl: http://www.geocities.com/paulclinger/soap.html

use strict;
use Data::Dumper;
use SOAP::Lite
  uri => 'http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1',
  proxy => 'http://raa.ruby-lang.org/soap/1.0/',
;
my $oSom = SOAP::Lite->new->getAllListings();
my $raRes = $oSom->result;
$raRes =  $oSom->fault unless($raRes);
print Dumper($raRes);
