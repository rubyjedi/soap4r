=begin
SOAP4R
Copyright (C) 2000 NAKAMURA Hiroshi.

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

require 'SOAPData'
require 'xmltreebuilder'


###
## SOAP elements
#
class SOAPMethod < SOAPCompoundBase
  public

  attr_reader :namespace
  attr_reader :name
  attr_reader :paramDef

  attr_accessor :paramNames
  attr_reader :paramTypes
  attr_reader :params

  attr_reader :retName
  attr_accessor :retVal

  def initialize( namespace, name, paramDef = nil )
    super( self.type.to_s )

    @namespace = namespace
    @name = name
    @paramDef = paramDef

    @paramNames = []
    @paramTypes = {}
    @params = {}
    @retName = nil
    @retVal = nil

    setParamDef() if @paramDef
  end

  def setParams( params )
    params.each do | param, data |
      @params[ param ] = data
    end
  end

  def encode( ns, forResponse = false )
    if !forResponse
      paramElem = @paramNames.collect { | param |
	@params[ param ].encode( ns.clone, param )
      }
      Element.new( ns.name( @namespace, @name ), nil, paramElem )
    else
      retElem = nil
      if retVal.is_a?( SOAPStruct )
	children = retVal.collect { | param, data |
	  data.encode( ns.clone, param )
	}
	retElem = Element.new( 'return', nil, children )
      else
	retElem = retVal.encode( ns.clone, 'return' )
      end
      Element.new( ns.name( @namespace, @name ), nil, retElem )
    end
  end

  private

  def setParamDef()
    @paramDef.each do | pair |
      type, name = pair
      type.scan( /[^,\s]+/ ).each do | typeToken |
	case typeToken
	when 'in'
	  @paramNames.push( name )
	  @paramTypes[ name ] = 1
	when 'out'
	  @paramNames.push( name )
	  @paramTypes[ name ] = 2
	when 'retval'
	  if ( @retName )
	    raise MethodDefinitionError.new( 'Duplicated retval' )
	  end
	  @retName = name
	else
	  raise MethodDefinitionError.new( 'Unknown type: ' << typeToken )
	end
      end
    end
  end

  # Module function

  public

  def self.decode( ns, elem )
    retVal = nil
    outParams = {}
    elem.childNodes.each do | child |
      next if ( isEmptyText( child ))
      childNS = ns.clone
      parseNS( childNS, child )
      if ( !retVal )
	retVal = decodeChild( childNS, child )
      else
	# ToDo: [in/out] or [out] parameters here...
	raise NotImplementError.new( '"out" parameters not supported.' )
      end
    end

    elemNamespace, elemName = ns.parse( elem.nodeName )
    m = SOAPMethod.new( elemNamespace, elemName )

    m.retVal = retVal
    #m.setParams( outParams )
    m
  end
end


class SOAPFault < SOAPCompoundBase
  public

  attr_reader :faultCode
  attr_reader :faultString
  attr_reader :faultActor
  attr_reader :detail
  attr_reader :options

  def initialize( faultCode, faultString, faultActor, detail = nil, options = [] )
    super( self.type.to_s )
    @faultCode = faultCode
    @faultString = faultString
    @faultActor = faultActor
    @detail = detail
    @options = options
  end

  def encode( ns )
    # Caution: never been executed!!
    faultElems = [ @faultCode.encode( ns, 'faultcode' ),
      @faultString.encode( ns, 'faultstring' ),
      @faultActor.encode( ns, 'faultactor' ) ]
    faultElems.push( @detail.encode( ns, 'detail' )) if @detail
    @options.each do | opt |
      paramElem.push( opt.encode( ns ))
    end
    Element.new( ns.name( EnvelopeNamespace, 'Fault' ), nil, faultElems )
  end

  # Module function

  public

  def self.decode( ns, elem )
    faultCode = nil
    faultString = nil
    faultActor = nil
    detail = nil
    options = []
    elem.childNodes.each do | child |
      next if ( isEmptyText( child ))
      childNS = ns.clone
      parseNS( childNS, child )

      if ( childNS.compare( EnvelopeNamespace, 'faultcode', child.nodeName ))
	raise FormatDecodeError.new( 'Duplicated faultcode in Fault' ) if faultCode
	faultCode = SOAPInteger.decode( childNS, child )

      elsif ( childNS.compare( EnvelopeNamespace, 'faultstring', child.nodeName ))
	raise FormatDecodeError.new( 'Duplicated faultstring in Fault' ) if faultString
	faultString = SOAPString.decode( childNS, child )

      elsif ( childNS.compare( EnvelopeNamespace, 'faultactor', child.nodeName ))
	raise FormatDecodeError.new( 'Duplicated faultactor in Fault' ) if faultActor
	faultActor = SOAPString.decode( childNS, child )

      elsif ( childNS.compare( EnvelopeNamespace, 'detail', child.nodeName ))
	raise FormatDecodeError.new( 'Duplicated detail in Fault' ) if detail
	detail = decodeChild( childNS, child )

      else
	options.push( decodeChild( childNS, child ))
      end
    end

    SOAPFault.new( faultCode, faultString, faultActor, detail, options )
  end
end


class SOAPBody < SOAPCompoundBase
  public

  attr_reader :data
  attr_reader :isFault

  def initialize( data, isFault = false )
    super( self.type.to_s )
    @data = data
    @isFault = isFault
  end

  def encode( ns, forResponse = false )
    attrs = []
    contents = nil
    if @isFault
      contents = @data.encode( ns )
    else
      attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), EncodingNamespace ))
      contents = @data.encode( ns, forResponse )
    end

    Element.new( ns.name( EnvelopeNamespace, 'Body' ), attrs, contents )
  end

  # Module function

  public

  def self.decode( ns, elem )
    data = nil
    isFault = false
    result = []

    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      if ( isEmptyText( child ))
	# Nothing to do.
      elsif ( childNS.compare( EnvelopeNamespace, 'Fault', child.nodeName ))
	data = SOAPFault.decode( childNS, child )
	isFault = true
      elsif !data
	data = SOAPMethod.decode( childNS, child )
      else
	# ToDo: May be a pointer...
	result.push( child )
	raise FormatDecodeError.new( 'Unknown node name: ' << child.nodeName )
      end
    end

    # ToDo: Must resolve pointers in result...

    SOAPBody.new( data, isFault )
  end
end


class SOAPHeaderItem < SOAPCompoundBase
  public

  attr_reader :namespace
  attr_reader :name
  attr_accessor :content
  attr_accessor :mustUnderstand
  attr_accessor :encodingStyle

  def initialize( namespace, name, content, mustUnderstand = false, encodingStyle = nil )
    super( self.type.to_s )
    @namespace = namespace
    @name = name
    @content = content
    @mustUnderstand = mustUnderstand
    @encodingStyle = encodingStyle
  end

  def encode( ns )
    return nil if @name.empty?
    attrs = []
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrMustUnderstand ), ( @mustUnderstand ? '1' : '0' )))
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), @encodingStyle )) if @encodingStyle
    Element.new( ns.name( @namespace, @name ), attrs, @content )
  end

  # Module function

  public

  def self.decode( ns, elem )
    mustUnderstand = nil
    encodingStyle = nil
    elem.attributes.each do | attr |
      name = attr.nodeName
      if ( ns.compare( EnvelopeNamespace, AttrMustUnderstand, name ))
	raise FormatDecodeError.new( 'Duplicated mustUnderstand in HeaderItem' ) if mustUnderstand
	mustUnderstand = attr.nodeValue
      elsif ( ns.compare( EnvelopeNamespace, AttrEncodingStyle, name ))
	raise FormatDecodeError.new( 'Duplicated encodingStyle in HeaderItem' ) if encodingStyle
    	encodingStyle = attr.nodeValue
      else
    	raise FormatDecodeError.new( 'Unknown attribute: ' << name )
      end
    end
    elemNamespace, elemName = ns.parse( elem.nodeName )

    # Convert NodeList to simple Array.
    childArray = []
    elem.childNodes.each do | child |
      childArray.push( child )
    end

    SOAPHeaderItem.new( elemNamespace, elemName, childArray, mustUnderstand, encodingStyle )
  end
end


class SOAPHeader < SOAPArray
  public

  def initialize()
    super( self.type.to_s )
  end

  def encode( ns )
    children = @data.collect { | child |
      child.encode( ns.clone )
    }
    Element.new( ns.name( EnvelopeNamespace, 'Header' ), nil, children )
  end

  def length
    @data[ 0 ].length
  end

  # Module function

  public

  def self.decode( ns, elem )
    s = SOAPHeader.new()
    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      next if ( isEmptyText( child ))
      s.add( SOAPHeaderItem.decode( childNS, child ))
    end
    s
  end
end


class SOAPEnvelope < SOAPCompoundBase
  public

  attr_reader :header
  attr_reader :body

  def initialize( initHeader, initBody )
    super( self.type.to_s )
    @header = initHeader
    @body = initBody
  end

  def encode( ns )
    # Namespace preloading.
    attrs = ns.namespaceTag.collect { | namespace, tag |
      if ( tag == '' )
	Attr.new( 'xmlns' , namespace )
      else
	Attr.new( 'xmlns:' << tag, namespace )
      end
    }

    contents = []
    contents.push( @header.encode( ns )) if @header and @header.length > 0
    contents.push( @body.encode( ns ))

    Element.new( ns.name( EnvelopeNamespace, 'Envelope' ), attrs, contents )
  end

  # Module function

  public

  def self.decode( ns, doc )
    if ( doc.childNodes.size != 1 )
      raise FormatDecodeError.new( 'Envelope must be a child.' )
    end

    elem = doc.childNodes[ 0 ]
    parseNS( ns, elem )

    if ( !ns.compare( EnvelopeNamespace, 'Envelope', elem.nodeName ))
      raise FormatDecodeError.new( 'Envelope not found.' )
    end

    header = nil
    body = nil
    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      name = child.nodeName
      if ( isEmptyText( child ))
	# Nothing to do.
      elsif ( childNS.compare( EnvelopeNamespace, 'Header', name ))
	raise FormatDecodeError.new( 'Duplicated Header in Envelope' ) if header
	header = SOAPHeader.decode( childNS, child )
      elsif ( childNS.compare( EnvelopeNamespace, 'Body', name ))
	raise FormatDecodeError.new( 'Duplicated Body in Envelope' ) if body
	body = SOAPBody.decode( childNS, child )
      else
	raise FormatDecodeError.new( 'Unknown scoping element: ' << name )
      end
    end

    SOAPEnvelope.new( header, body )
  end
end
