=begin
SOAP4R - RPC utility.
Copyright (C) 2000, 2001 NAKAMURA Hiroshi.

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

require 'soap/baseData'


module SOAPRPCUtils
  class SOAPMethod < SOAPCompoundBase
    public

    attr_reader :namespace
    attr_reader :name

    attr_reader :paramDef
    attr_accessor :paramNames
    attr_reader :paramTypes
    attr_reader :params

    attr_accessor :retName
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
  
      setParamDef if @paramDef
    end
  
    def setParams( params )
      params.each do | param, data |
        @params[ param ] = data
      end
    end
  
    def encode( ns )
      attrs = []
      createNS( attrs, ns )
      attrs.push( datatypeAttr( ns ))
      if !retVal
        paramElem = @paramNames.collect { | param |
          @params[ param ].encode( ns.clone, param )
        }
        Element.new( ns.name( @namespace, @name ), attrs, paramElem )
      else
        retElem = retVal.encode( ns.clone, 'return' )
        Element.new( ns.name( @namespace, responseTypeName() ), attrs, retElem )
      end
    end
  
    private

    def datatypeAttr( ns )
      Attr.new( ns.name( XSD::InstanceNamespace, 'type' ),
	ns.name( @namespace, @name ))
    end

    def createNS( attrs, ns )
      unless ns[ @namespace ]
        tag = ns.assign( @namespace )
        attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
      end
    end

    def setParamDef
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
  
    def responseTypeName
      @name + 'Response'
    end

    # Module function
  
    public
  
    # CAUTION: Not tested.
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


  ###
  ## Convert parameter
  #
  RubyTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/1.6'
  RubyCustomTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/custom'

  def obj2soap( obj )
    case obj
    when SOAPBasetypeUtils
      obj
    when NilClass
      SOAPNull.new
    when TrueClass, FalseClass
      SOAPBoolean.new( obj )
    when String
      SOAPString.new( obj )
    when Time
      SOAPTimeInstant.new( obj )
    when Fixnum
      SOAPInt.new( obj )
    when Integer
      SOAPInteger.new( obj )
    when Array
      param = SOAPArray.new
      param.typeNamespace = getNamespace( obj ) || RubyTypeNamespace
      obj.each do | var |
	param.add( obj2soap( var ))
      end
      param
    when Struct
      param = SOAPStruct.new( obj.type.to_s )
      param.typeNamespace = getNamespace( obj ) || RubyTypeNamespace
      obj.members.each do |member|
	param.add( member, obj2soap( obj[ member ] ))
      end
      param
    else
      typeName = getTypeName( obj ) || obj.type.to_s
      param = SOAPStruct.new( typeName  )
      param.typeNamespace = getNamespace( obj ) || RubyCustomTypeNamespace
      obj.instance_variables.each do | var |
	name = var.dup.sub!( /^@/, '' )
	param.add( name, obj2soap( obj.instance_eval( var )))
      end
      param
    end
  end

  def getTypeName( obj )
    ret = nil
    begin
      ret = obj.instance_eval( "@@typeName" )
    rescue NameError
      # Ignored.
    end
    ret
  end

  def getNamespace( obj )
    ret = nil
    begin
      ret = obj.instance_eval( "@@namespace" )
    rescue NameError
      # Ignored.
    end
    ret
  end

  def soap2obj( node )
    case node
    when SOAPNull
      nil
    when SOAPBoolean, SOAPString, SOAPInteger, SOAPInt, SOAPTimeInstant
      node.data
    when SOAPArray
      node.collect { |elem| soap2obj( elem ) }
    when SOAPStruct
      struct2obj( node )
    else
      node
    end
  end

  def struct2obj( node )
    obj = nil
    begin
      klass = eval( capitalize( node.typeName ))
      if getNamespace( klass ) != node.typeNamespace
	raise NameError.new()
      elsif getTypeName( klass ) and ( getTypeName( klass ) != node.typeName )
	raise NameError.new()
      end
      Thread.critical = true
      klass.module_eval( "alias __initialize initialize; def initialize; end" )
      obj = klass.new
      klass.module_eval( "undef initialize; alias initialize __initialize" )
      Thread.critical = false
      node.each do |name, value|
	begin
	  obj.send( name + "=", soap2obj( value ))
	rescue NameError
	  # Cannot be set.  Ignored.
	end
      end
    rescue NameError
      klass = Struct.new( structName(node.typeName), *node.array )
      obj = klass.new( *( node.collect { |name, value| soap2obj( value ) } ))
    end

    obj
  end

  def structName( name )
    capitalize( name )
  end

  def capitalize( target )
    target.gsub('^([a-z])') { $1.tr!('[a-z]', '[A-Z]') }
  end
end
