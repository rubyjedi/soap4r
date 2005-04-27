#!/usr/bin/env ruby

$KCODE = 'EUC'
$RWIKI_DIR = 'rwiki'
$RWIKI_URI = 'druby://localhost:8470'

$:.unshift($RWIKI_DIR)
$:.unshift(File::join($RWIKI_DIR, 'lib'))

require 'cgi'
require 'drb/drb'
require 'rw-lib'
require 'soap/rpc/cgistub'

NS = 'http://www.ruby-lang.org/xmlns/soap/interface/RWiki/0.0.1'

class RWikiSOAPApp < SOAP::RPC::CGIStub
  def methodDef
    add_method(self, 'find')
    add_method(self, 'view')
    add_method(self, 'src')
    add_method(self, 'setSrcAndView')
  end
  
  def find(keyword)
    $rwiki.find(keyword)
  end

  def src(name)
    $rwiki.src(name)
  end

  def view(name, env)
    $rwiki.view(name, env)
  end

  def setSrcAndView(name, src, env)
    $rwiki.set_src_and_view(name, src, env)
  end
end

DRb.start_service()
$rwiki = DRbObject.new(nil, $RWIKI_URI)
RWikiSOAPApp.new("InteropApp", NS).start
