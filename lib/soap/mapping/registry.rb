=begin
SOAP4R - Mapping registry.
Copyright (C) 2000, 2001, 2002, 2003 NAKAMURA Hiroshi.

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
require 'soap/charset'
require 'soap/mapping/mapping'
require 'soap/mapping/factory'
require 'soap/mapping/rubytypeFactory'


module SOAP


module Marshallable
  # @@typeNamespace = Mapping::RubyCustomTypeNamespace
end


module Mapping

  
module MappedException; end


RubyTypeName = XSD::QName.new(RubyTypeInstanceNamespace, 'rubyType')


# Inner class to pass an exception.
class SOAPException; include Marshallable
  attr_reader :exceptionTypeName, :message, :backtrace, :cause
  def initialize(e)
    @exceptionTypeName = Mapping.getElementNameFromName(e.class.to_s)
    @message = e.message
    @backtrace = e.backtrace
    @cause = e
  end

  def to_e
    if @cause.is_a?(::Exception)
      @cause.extend(::SOAP::Mapping::MappedException)
      return @cause
    end
    klass = Mapping.getClassFromName(
      Mapping.getNameFromElementName(@exceptionTypeName.to_s))
    if klass.nil?
      raise RuntimeError.new(@message)
    end
    unless klass <= ::Exception
      raise NameError.new
    end
    obj = klass.new(@message)
    obj.extend(::SOAP::Mapping::MappedException)
    obj
  end

  def set_backtrace(e)
    e.set_backtrace(
      if @backtrace.is_a?(Array)
        @backtrace
      else
        [@backtrace.inspect]
      end
   )
  end
end


# For anyType object.
class Object; include Marshallable
  def setProperty(name, value)
    varName = name
    begin
      instance_eval <<-EOS
        def #{ varName }
          @#{ varName }
        end

        def #{ varName }=(newMember)
          @#{ varName } = newMember
        end
      EOS
      self.send(varName + '=', value)
    rescue SyntaxError
      varName = safeName(varName)
      retry
    end

    varName
  end

  def members
    instance_variables.collect { |str| str[1..-1] }
  end

  def [](name)
    if self.respond_to?(name)
      self.send(name)
    else
      self.send(safeName(name))
    end
  end

  def []=(name, value)
    if self.respond_to?(name)
      self.send(name + '=', value)
    else
      self.send(safeName(name) + '=', value)
    end
  end

private

  def safeName(name)
    require 'md5'
    "var_" << MD5.new(name).hexdigest
  end
end


class MappingError < Error; end


class Registry
  class Map
    def initialize(mappingRegistry)
      @map = []
      @registry = mappingRegistry
    end

    def obj2soap(klass, obj)
      @map.each do |objKlass, soapKlass, factory, info|
        if klass == objKlass or
            (info[:derivedClass] and klass <= objKlass)
          ret = factory.obj2soap(soapKlass, obj, info, @registry)
          return ret if ret
        end
      end
      nil
    end

    def soap2obj(klass, node)
      @map.each do |objKlass, soapKlass, factory, info|
        if klass == soapKlass or
            (info[:derivedClass] and klass <= soapKlass)
          conv, obj = factory.soap2obj(objKlass, node, info, @registry)
          return true, obj if conv
        end
      end
      return false
    end

    # Give priority to former entry.
    def init(initMap = [])
      clear
      initMap.reverse_each do |objKlass, soapKlass, factory, info|
        add(objKlass, soapKlass, factory, info)
      end
    end

    # Give priority to latter entry.
    def add(objKlass, soapKlass, factory, info)
      info ||= {}
      @map.unshift([objKlass, soapKlass, factory, info])
    end

    def clear
      @map.clear
    end

    def searchMappedSOAPClass(targetRubyClass)
      @map.each do |objKlass, soapKlass, factory, info|
        if objKlass == targetRubyClass
          return soapKlass
        end
      end
      nil
    end

    def searchMappedRubyClass(targetSOAPClass)
      @map.each do |objKlass, soapKlass, factory, info|
        if soapKlass == targetSOAPClass
          return objKlass
        end
      end
      nil
    end
  end

  StringFactory = StringFactory_.new
  BasetypeFactory = BasetypeFactory_.new
  DateTimeFactory = DateTimeFactory_.new
  ArrayFactory = ArrayFactory_.new
  Base64Factory = Base64Factory_.new
  TypedArrayFactory = TypedArrayFactory_.new
  TypedStructFactory = TypedStructFactory_.new

  HashFactory = HashFactory_.new

  SOAPBaseMap = [
    [::NilClass,     ::SOAP::SOAPNil,        BasetypeFactory],
    [::TrueClass,    ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::FalseClass,   ::SOAP::SOAPBoolean,    BasetypeFactory],
    [::String,       ::SOAP::SOAPString,     StringFactory],
    [::Date,         ::SOAP::SOAPDateTime,   BasetypeFactory],
    [::Date,         ::SOAP::SOAPDate,       BasetypeFactory],
    [::Time,         ::SOAP::SOAPDateTime,   BasetypeFactory],
    [::Time,         ::SOAP::SOAPTime,       BasetypeFactory],
    [::Float,        ::SOAP::SOAPDouble,     BasetypeFactory,
      { :derivedClass => true }],
    [::Float,        ::SOAP::SOAPFloat,      BasetypeFactory,
      { :derivedClass => true }],
    [::Integer,      ::SOAP::SOAPInt,        BasetypeFactory,
      { :derivedClass => true }],
    [::Integer,      ::SOAP::SOAPLong,       BasetypeFactory,
      { :derivedClass => true }],
    [::Integer,      ::SOAP::SOAPInteger,    BasetypeFactory,
      { :derivedClass => true }],
    [::Integer,      ::SOAP::SOAPShort,      BasetypeFactory,
      { :derivedClass => true }],
    [::URI::Generic, ::SOAP::SOAPAnyURI,     BasetypeFactory,
      { :derivedClass => true }],
    [::String,       ::SOAP::SOAPBase64,     Base64Factory],
    [::String,       ::SOAP::SOAPHexBinary,  Base64Factory],
    [::String,       ::SOAP::SOAPDecimal,    BasetypeFactory],
    [::String,       ::SOAP::SOAPDuration,   BasetypeFactory],
    [::String,       ::SOAP::SOAPGYearMonth, BasetypeFactory],
    [::String,       ::SOAP::SOAPGYear,      BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonthDay,  BasetypeFactory],
    [::String,       ::SOAP::SOAPGDay,       BasetypeFactory],
    [::String,       ::SOAP::SOAPGMonth,     BasetypeFactory],
    [::String,       ::SOAP::SOAPQName,      BasetypeFactory],

    [::Array,        ::SOAP::SOAPArray,      ArrayFactory],

    [::Hash,         ::SOAP::SOAPStruct,     HashFactory],
    [::SOAP::Mapping::SOAPException,
                      ::SOAP::SOAPStruct,     TypedStructFactory,
      { :type => XSD::QName.new(RubyCustomTypeNamespace, "SOAPException") }
   ],
 ]

  def initialize(config = {})
    @config = config
    @map = Map.new(self)
    @map.init(SOAPBaseMap)
    allowUntypedStruct = @config.has_key?(:allowUntypedStruct) ?
      @config[:allowUntypedStruct] : true
    allowOriginalMapping = @config.has_key?(:allowOriginalMapping) ?
      @config[:allowOriginalMapping] : false
    @rubytypeFactory = RubytypeFactory.new(
      :allowUntypedStruct => allowUntypedStruct,
      :allowOriginalMapping => allowOriginalMapping
   )
    @defaultFactory = @rubytypeFactory
    @obj2soapExceptionHandler = nil
    @soap2objExceptionHandler = nil
  end

  def add(objKlass, soapKlass, factory, info = nil)
    @map.add(objKlass, soapKlass, factory, info)
  end
  alias :set :add

  # This mapping registry ignores type hint.
  def obj2soap(klass, obj, type = nil)
    ret = nil
    if obj.is_a?(SOAPStruct) || obj.is_a?(SOAPArray)
      obj.replace do |ele|
        Mapping._obj2soap(ele, self)
      end
      return obj
    elsif obj.is_a?(SOAPBasetype)
      return obj
    end
    begin 
      ret = @map.obj2soap(klass, obj) ||
        @defaultFactory.obj2soap(klass, obj, nil, self)
    rescue MappingError
    end
    return ret if ret

    if @obj2soapExceptionHandler
      ret = @obj2soapExceptionHandler.call(obj) { |yieldObj|
        Mapping._obj2soap(yieldObj, self)
      }
    end
    return ret if ret

    raise MappingError.new("Cannot map #{ klass.name } to SOAP/OM.")
  end

  def soap2obj(klass, node)
    if node.extraAttrs.has_key?(RubyTypeName)
      conv, obj = @rubytypeFactory.soap2obj(klass, node, nil, self)
      return obj if conv
    else
      conv, obj = @map.soap2obj(klass, node)
      return obj if conv
      conv, obj = @defaultFactory.soap2obj(klass, node, nil, self)
      return obj if conv
    end

    if @soap2objExceptionHandler
      begin
        return @soap2objExceptionHandler.call(node) { |yieldNode|
          Mapping._soap2obj(yieldNode, self)
        }
      rescue Exception
      end
    end

    raise MappingError.new("Cannot map #{ node.type.name } to Ruby object.")
  end

  def defaultFactory=(newFactory)
    @defaultFactory = newFactory
  end

  def obj2soapExceptionHandler=(newHandler)
    @obj2soapExceptionHandler = newHandler
  end

  def soap2objExceptionHandler=(newHandler)
    @soap2objExceptionHandler = newHandler
  end

  def searchMappedSOAPClass(rubyClass)
    @map.searchMappedSOAPClass(rubyClass)
  end

  def searchMappedRubyClass(soapClass)
    @map.searchMappedRubyClass(soapClass)
  end
end


class WSDLMappingRegistry
  include TraverseSupport

  attr_reader :complexTypes

  def initialize(wsdl, portType, config = {})
    @wsdl = wsdl
    @portType = portType
    @config = config
    @complexTypes = @wsdl.getComplexTypesWithMessages(portType)
    @obj2soapExceptionHandler = nil
  end

  def obj2soap(klass, obj, typeQName)
    soapObj = nil
    if obj.nil?
      soapObj = SOAPNil.new
    elsif obj.is_a?(SOAPBasetype)
      soapObj = obj
    elsif obj.is_a?(SOAPStruct) && (type = @complexTypes[obj.type])
      soapObj = obj
      markMarshalledObj(obj, soapObj)
      elements2soap(obj, soapObj, type.content.elements)
    elsif obj.is_a?(SOAPArray) && (type = @complexTypes[obj.type])
      contentType = type.getChildType
      soapObj = obj
      markMarshalledObj(obj, soapObj)
      obj.replace do |ele|
        Mapping._obj2soap(ele, self, contentType)
      end
    elsif (type = @complexTypes[typeQName])
      case type.compoundType
      when :TYPE_STRUCT
        soapObj = struct2soap(obj, typeQName, type)
      when :TYPE_ARRAY
        soapObj = array2soap(obj, typeQName, type)
      end
    elsif (type = TypeMap[typeQName])
      soapObj = base2soap(obj, type)
    end
    return soapObj if soapObj

    if @obj2soapExceptionHandler
      soapObj = @obj2soapExceptionHandler.call(obj) { |yieldObj|
        Mapping._obj2soap(yieldObj, self)
      }
    end
    return soapObj if soapObj

    raise MappingError.new("Cannot map #{ klass.name } to SOAP/OM.")
  end

  def soap2obj(klass, node)
    raise RuntimeError.new("#{ self } is for obj2soap only.")
  end

  def obj2soapExceptionHandler=(newHandler)
    @obj2soapExceptionHandler = newHandler
  end

private

  def base2soap(obj, type)
    soapObj = nil
    if type <= XSD::XSDString
      soapObj = type.new(Charset.isCES(obj, $KCODE) ?
        Charset.codeConv(obj, $KCODE, Charset.getEncoding) : obj)
      markMarshalledObj(obj, soapObj)
    else
      soapObj = type.new(obj)
    end
    soapObj
  end

  def struct2soap(obj, typeQName, type)
    soapObj = SOAPStruct.new(typeQName)
    markMarshalledObj(obj, soapObj)
    elements2soap(obj, soapObj, type.content.elements)
    soapObj
  end

  def array2soap(obj, soapObj, type)
    contentType = type.getChildType
    soapObj = SOAPArray.new(ValueArrayName, 1, contentType)
    markMarshalledObj(obj, soapObj)
    obj.each do |item|
      soapObj.add(Mapping._obj2soap(item, self, contentType))
    end
    soapObj
  end

  def elements2soap(obj, soapObj, elements)
    elements.each do |elementName, element|
      childObj = obj.instance_eval('@' << elementName)
      soapObj.add(elementName,
        Mapping._obj2soap(childObj, self, element.type))
    end
  end
end


DefaultRegistry = Registry.new


end
end
