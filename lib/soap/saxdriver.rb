=begin
SOAP4R - SOAP xmlparser library.
Copyright (C) 2001, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'soap/parser'
require 'saxdriver'
require 'tempfile'


module SOAP


class SOAPSAXDriver < SOAPParser
  def initialize(*vars)
    super(*vars)
    @parser = XML::Parser::SAXDriver.new
    handler = Handler.new(self)
    @parser.setDocumentHandler(handler)
    @parser.setErrorHandler(handler)
  end

  class Handler < XML::SAX::HandlerBase
    def initialize(driver)
      @driver = driver
    end

    def getAttrs(attrs)
      ret = {}
      for i in 0...attrs.getLength
	ret[attrs.getName(i)] = attrs.getValue(i)
      end
      ret
    end

    # def startDocument; end
    # def endDocument; end

    def start_element(name, attr)
      @driver.start_element(name, getAttrs(attr))
    end

    def end_element(name)
      @driver.end_element(name)
    end

    def characters(ch, start, length)
      @driver.characters(ch[start, length])
    end

    # def processingInstruction(target, data); end

    # def notationDecl(name, pubid, sysid); end

    # def unparsedEntityDecl(name, pubid, sysid, notation); end

    # def resolveEntity(pubid, sysid); end

    # def setDocumentLocator(loc)
    # end
    # loc.getSystemId and loc.getLineNumber might be useful.

    def fatalError(e)
      raise e
    end
  end

  def do_parse(string_or_readable)
    f = Tempfile.new("SOAP4R_SOAPSAXDriver")
    if string_or_readable.is_a?(String)
      f.write(string_or_readable)
    else
      f.write(string_or_readable.read)
    end
    f.close(false)	# Close but not removed
    @parser.parse(f.path)
    # 
  end
end


end
