=begin
SOAP4R - Ruby type mapping factory.
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


module SOAP
module Mapping


class RubytypeFactory < Factory
  TYPE_STRING = 'String'
  TYPE_ARRAY = 'Array'
  TYPE_REGEXP = 'Regexp'
  TYPE_RANGE = 'Range'
  TYPE_CLASS = 'Class'
  TYPE_MODULE = 'Module'
  TYPE_SYMBOL = 'Symbol'
  TYPE_STRUCT = 'Struct'
  TYPE_HASH = 'Map'
  
  def initialize(config = {})
    @config = config
    @allowUntypedStruct = @config.has_key?(:allowUntypedStruct) ?
      @config[:allowUntypedStruct] : true
    @allowOriginalMapping = @config.has_key?(:allowOriginalMapping) ?
      @config[:allowOriginalMapping] : false
  end

  def obj2soap(soapKlass, obj, info, map)
    param = nil
    case obj
    when String
      unless @allowOriginalMapping
        return nil
      end
      unless Charset.isCES(obj, $KCODE)
        return nil
      end
      encoded = Charset.codeConv(obj, $KCODE, Charset.getEncoding)
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_STRING))
      markMarshalledObj(obj, param)
      param.add('string', SOAPString.new(encoded))
      if obj.class != String
        param.extraAttrs[RubyTypeName] = obj.class.name
      end
      addiv2soap(param, obj, map)
    when Array
      unless @allowOriginalMapping
        return nil
      end
      arrayType = getObjType(obj)
      if arrayType.name
        arrayType.namespace ||= RubyTypeNamespace
      else
        arrayType = XSD::AnyTypeName
      end
      if obj.instance_variables.empty?
        param = SOAPArray.new(ValueArrayName, 1, arrayType)
        markMarshalledObj(obj, param)
        obj.each do |var|
          param.add(Mapping._obj2soap(var, map))
        end
      else
        param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_ARRAY))
        markMarshalledObj(obj, param)
        ary = SOAPArray.new(ValueArrayName, 1, arrayType)
        obj.each do |var|
          ary.add(Mapping._obj2soap(var, map))
        end
        param.add('array', ary)
        addiv2soap(param, obj, map)
      end
      if obj.class != Array
        param.extraAttrs[RubyTypeName] = obj.class.name
      end
    when Regexp
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_REGEXP))
      markMarshalledObj(obj, param)
      if obj.class != Regexp
        param.extraAttrs[RubyTypeName] = obj.class.name
      end
      param.add('source', SOAPBase64.new(obj.source))
      if obj.respond_to?('options')
        # Regexp#options is from Ruby/1.7
        options = obj.options
      else
        options = 0
        obj.inspect.sub(/^.*\//, '').each_byte do |c|
          options += case c
            when ?i
              1
            when ?x
              2
            when ?m
              4
            when ?n
              16
            when ?e
              32
            when ?s
              48
            when ?u
              64
            end
        end
      end
      param.add('options', SOAPInt.new(options))
      addiv2soap(param, obj, map)
    when Range
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_RANGE))
      markMarshalledObj(obj, param)
      if obj.class != Range
        param.extraAttrs[RubyTypeName] = obj.class.name
      end
      param.add('begin', Mapping._obj2soap(obj.begin, map))
      param.add('end', Mapping._obj2soap(obj.end, map))
      param.add('exclude_end', SOAP::SOAPBoolean.new(obj.exclude_end?))
      addiv2soap(param, obj, map)
    when Hash
      unless @allowOriginalMapping
        return nil
      end
      if obj.respond_to?(:default_proc) && obj.default_proc
        raise ArgumentError.new("cannot dump hash with default proc")
      end
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_HASH))
      markMarshalledObj(obj, param)
      if obj.class != Hash
        param.extraAttrs[RubyTypeName] = obj.class.name
      end
      obj.each do |key, value|
        elem = SOAPStruct.new # Undefined type.
        elem.add("key", Mapping._obj2soap(key, map))
        elem.add("value", Mapping._obj2soap(value, map))
        param.add("item", elem)
      end
      param.add('default', Mapping._obj2soap(obj.default, map))
      addiv2soap(param, obj, map)
    when Class
      if obj.name.empty?
        raise ArgumentError.new("Can't dump anonymous class #{ obj }.")
      end
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_CLASS))
      markMarshalledObj(obj, param)
      param.add('name', SOAPString.new(obj.name))
      addiv2soap(param, obj, map)
    when Module
      if obj.name.empty?
        raise ArgumentError.new("Can't dump anonymous module #{ obj }.")
      end
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_MODULE))
      markMarshalledObj(obj, param)
      param.add('name', SOAPString.new(obj.name))
      addiv2soap(param, obj, map)
    when Symbol
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_SYMBOL))
      markMarshalledObj(obj, param)
      param.add('id', SOAPString.new(obj.id2name))
      addiv2soap(param, obj, map)
    when Exception
      typeStr = Mapping.getElementNameFromName(obj.class.to_s)
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, typeStr))
      markMarshalledObj(obj, param)
      param.add('message', Mapping._obj2soap(obj.message, map))
      param.add('backtrace', Mapping._obj2soap(obj.backtrace, map))
      addiv2soap(param, obj, map)
    when Struct
      param = SOAPStruct.new(XSD::QName.new(RubyTypeNamespace, TYPE_STRUCT))
      markMarshalledObj(obj, param)
      param.add('type', typeElem = SOAPString.new(obj.class.to_s))
      memberElem = SOAPStruct.new
      obj.members.each do |member|
        memberElem.add(Mapping.getElementNameFromName(member),
          Mapping._obj2soap(obj[member], map))
      end
      param.add('member', memberElem)
      addiv2soap(param, obj, map)
    when IO, Binding, Continuation, Data, Dir, File::Stat, MatchData, Method,
        Proc, Thread, ThreadGroup 
      return nil
    when ::SOAP::Mapping::Object
      param = SOAPStruct.new(XSD::AnyTypeName)
      markMarshalledObj(obj, param)
      setiv2soap(param, obj, map)   # addiv2soap?
    else
      if obj.class.name.empty?
        raise ArgumentError.new("Can't dump anonymous class #{ obj }.")
      end
      unless obj.singleton_methods.empty?
        raise TypeError.new("singleton can't be dumped #{ obj }")
      end
      singleton_class = class << obj; self; end
      unless singleton_class.instance_variables.empty?
        raise TypeError.new("singleton can't be dumped #{ obj }")
      end
      type = getClassType(obj.class)
      type.name ||= Mapping.getElementNameFromName(obj.class.to_s)
      type.namespace ||= RubyCustomTypeNamespace
      param = SOAPStruct.new(type)
      markMarshalledObj(obj, param)
      if obj.class <= Marshallable
        setiv2soap(param, obj, map)
      else
        setiv2soap(param, obj, map) # Should not be marshalled?
      end
    end
    param
  end

  def soap2obj(objKlass, node, info, map)
    if node.type.namespace == RubyTypeNamespace
      rubyType2obj(node, map)
    elsif node.type == XSD::AnyTypeName or node.type == XSD::AnySimpleTypeName
      anyType2obj(node, map)
    else
      unknownType2obj(node, map)
    end
  end

private

  def rubyType2obj(node, map)
    obj = nil
    case node.class
    when SOAPString
      klass = String
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      obj.replace(node.data)
      return true, obj
    when SOAPArray
      klass = Array
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      node.soap2array(obj) do |elem|
        elem ? Mapping._soap2obj(elem, map) : nil
      end
    end

    case node.type.name
    when TYPE_STRING
      klass = String
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      obj.replace(node['string'].data)
      setiv2obj(obj, node['ivars'], map)
    when TYPE_ARRAY
      klass = Array
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      node['array'].soap2array(obj) do |elem|
        elem ? Mapping._soap2obj(elem, map) : nil
      end
      setiv2obj(obj, node['ivars'], map)
    when TYPE_REGEXP
      klass = Regexp
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      source = node['source'].toString
      options = node['options'].data || 0
      obj.instance_eval { initialize(source, options) }
      setiv2obj(obj, node['ivars'], map)
    when TYPE_RANGE
      klass = Range
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      first = Mapping._soap2obj(node['begin'], map)
      last = Mapping._soap2obj(node['end'], map)
      exclude_end = node['exclude_end'].data
      obj.instance_eval { initialize(first, last, exclude_end) }
      setiv2obj(obj, node['ivars'], map)
    when TYPE_HASH
      unless @allowOriginalMapping
        return false
      end
      klass = Hash
      if (rubyType = node.extraAttrs[RubyTypeName])
        klass = Mapping.getClassFromName(rubyType)
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      node.each do |key, value|
        next unless key == 'item'
        obj[Mapping._soap2obj(value['key'], map)] =
          Mapping._soap2obj(value['value'], map)
      end
      if node.has_key?('default')
        obj.default = Mapping._soap2obj(node['default'], map)
      end
      setiv2obj(obj, node['ivars'], map)
    when TYPE_CLASS
      obj = Mapping.getClassFromName(node['name'].data)
      setiv2obj(obj, node['ivars'], map)
    when TYPE_MODULE
      obj = Mapping.getClassFromName(node['name'].data)
      setiv2obj(obj, node['ivars'], map)
    when TYPE_SYMBOL
      obj = node['id'].data.intern
      setiv2obj(obj, node['ivars'], map)
    when TYPE_STRUCT
      typeStr = Mapping.getNameFromElementName(node['type'].data)
      klass = Mapping.getClassFromName(typeStr)
      if klass.nil?
        klass = Mapping.getClassFromName(toType(typeStr))
      end
      if klass.nil?
        return false
      end
      unless klass <= ::Struct
        return false
      end
      obj = createEmptyObject(klass)
      markUnmarshalledObj(node, obj)
      node['member'].each do |name, value|
        obj[Mapping.getNameFromElementName(name)] =
          Mapping._soap2obj(value, map)
      end
      setiv2obj(obj, node['ivars'], map)
    else
      conv, obj = exception2obj(node, map)
      unless conv
        return false
      end
      setiv2obj(obj, node['ivars'], map)
    end
    return true, obj
  end

  def exception2obj(node, map)
    typeStr = Mapping.getNameFromElementName(node.type.name)
    klass = Mapping.getClassFromName(typeStr)
    if klass.nil?
      return false
    end
    unless klass <= Exception
      return false
    end
    message = Mapping._soap2obj(node['message'], map)
    backtrace = Mapping._soap2obj(node['backtrace'], map)
    obj = createEmptyObject(klass)
    obj = obj.exception(message)
    markUnmarshalledObj(node, obj)
    obj.set_backtrace(backtrace)
    setiv2obj(obj, node['ivars'], map)
    return true, obj
  end

  def anyType2obj(node, map)
    case node
    when SOAPBasetype
      return true, node.data
    when SOAPStruct
      klass = ::SOAP::Mapping::Object
      obj = klass.new
      markUnmarshalledObj(node, obj)
      node.each do |name, value|
        obj.setProperty(name, Mapping._soap2obj(value, map))
      end
      return true, obj
    else
      return false
    end
  end

  def unknownType2obj(node, map)
    if node.is_a?(SOAPStruct)
      obj = struct2obj(node, map)
      return true, obj if obj
      if !@allowUntypedStruct
        return false
      end
      return anyType2obj(node, map)
    else
      # Basetype which is not defined...
      return false
    end
  end

  def struct2obj(node, map)
    obj = nil
    typeStr = Mapping.getNameFromElementName(node.type.name)
    klass = Mapping.getClassFromName(typeStr)
    if klass.nil?
      klass = Mapping.getClassFromName(toType(typeStr))
    end
    if klass.nil?
      return nil
    end
    klassType = getClassType(klass)
    return nil unless node.type.match(klassType)
    obj = createEmptyObject(klass)
    markUnmarshalledObj(node, obj)
    setiv2obj(obj, node, map)
    obj
  end
end


end
end
