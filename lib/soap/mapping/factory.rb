=begin
SOAP4R - Mapping factory.
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


class Factory
  include TraverseSupport

  def obj2soap(soapKlass, obj, info, map)
    raise NotImplementError.new
    # return soapObj
  end

  def soap2obj(objKlass, node, info, map)
    raise NotImplementError.new
    # return convertSucceededOrNot, obj
  end

protected

  def getClassType(klass)
    name = if klass.class_variables.include?("@@typeName")
        klass.class_eval("@@typeName")
      else
        nil
      end
    namespace = if klass.class_variables.include?("@@typeNamespace")
        klass.class_eval("@@typeNamespace")
      else
        nil
      end
    XSD::QName.new(namespace, name)
  end

  def getObjType(obj)
    name = namespace = nil
    ivars = obj.instance_variables
    if ivars.include?("@typeName")
      name = obj.instance_eval("@typeName")
    end
    if ivars.include?("@typeNamespace")
      namespace = obj.instance_eval("@typeNamespace")
    end
    # Do not mix type and its namespace.
    if !name or !namespace
      getClassType(obj.class)
    else
      XSD::QName.new(namespace, name)
    end
  end

  if Object.respond_to?(:allocate)
    # ruby/1.7 or later.
    def createEmptyObject(klass)
      klass.allocate
    end
  else
    def createEmptyObject(klass)
      name = klass.name
      # Below line is from TANAKA, Akira's amarshal.rb.
      # See http://cvs.m17n.org/cgi-bin/viewcvs/amarshal/?cvsroot=ruby
      ::Marshal.load(sprintf("\004\006o:%c%s\000", name.length + 5, name))
    end
  end

  def setInstanceVariables(obj, values)
    values.each do |name, value|
      setter = name + "="
      if obj.respond_to?(setter)
        obj.__send__(setter, value)
      else
        obj.instance_eval("@#{ name } = value")
      end
    end
  end

  def setiv2obj(obj, node, map)
    return if node.nil?
    vars = {}
    node.each do |name, value|
      vars[Mapping.getNameFromElementName(name)] = Mapping._soap2obj(value, map)
    end
    setInstanceVariables(obj, vars)
  end

  def setiv2soap(node, obj, map)
    obj.instance_variables.each do |var|
      name = var.sub(/^@/, '')
      node.add(Mapping.getElementNameFromName(name),
        Mapping._obj2soap(obj.instance_eval(var), map))
    end
  end

  def addiv2soap(node, obj, map)
    return if obj.instance_variables.empty?
    ivars = SOAPStruct.new    # Undefined type.
    setiv2soap(ivars, obj, map)
    node.add('ivars', ivars)
  end

  # It breaks Thread.current[:SOAPMarshalDataKey].
  def markMarshalledObj(obj, soapObj)
    Thread.current[:SOAPMarshalDataKey][obj.__id__] = soapObj
  end

  # It breaks Thread.current[:SOAPMarshalDataKey].
  def markUnmarshalledObj(node, obj)
    Thread.current[:SOAPMarshalDataKey][node.id] = obj
  end

  def toType(name)
    capitalize(name)
  end

  def capitalize(target)
    target.gsub(/^([a-z])/) { $1.tr!('[a-z]', '[A-Z]') }
  end
end

class StringFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    begin
      if Charset.isCES(obj, $KCODE)
        encoded = Charset.codeConv(obj, $KCODE, Charset.getEncoding)
        soapObj = soapKlass.new(encoded)
      else
        return nil
      end
    rescue XSD::ValueSpaceError
      return nil
    end
    markMarshalledObj(obj, soapObj)
    soapObj
  end

  def soap2obj(objKlass, node, info, map)
    obj = Charset.codeConv(node.data, Charset.getEncoding, $KCODE)
    markUnmarshalledObj(node, obj)
    return true, obj
  end
end

class BasetypeFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    soapObj = nil
    begin
      soapObj = soapKlass.new(obj)
    rescue XSD::ValueSpaceError
      return nil
    end
    # Basetype except String should not be multiref-ed in SOAP/1.1.
    soapObj
  end

  def soap2obj(objKlass, node, info, map)
    obj = node.data
    markUnmarshalledObj(node, obj)
    return true, obj
  end
end

class DateTimeFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    soapObj = nil
    begin
      soapObj = soapKlass.new(obj)
    rescue XSD::ValueSpaceError
      return nil
    end
    markMarshalledObj(obj, soapObj)
    soapObj
  end

  def soap2obj(objKlass, node, info, map)
    obj = nil
    if objKlass == Time
      obj = node.to_time
      if obj.nil?
        # Is out of range as a Time
        return false
      end
    elsif objKlass == Date
      obj = node.data
    else
      return false
    end
    markUnmarshalledObj(node, obj)
    return true, obj
  end
end

class Base64Factory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    soapObj = soapKlass.new(obj)
    markMarshalledObj(obj, soapObj) if soapObj
    soapObj
  end

  def soap2obj(objKlass, node, info, map)
    obj = node.toString
    markUnmarshalledObj(node, obj)
    return true, obj
  end
end

class ArrayFactory_ < Factory
  # [[1], [2]] is converted to Array of Array, not 2-D Array.
  # To create M-D Array, you must call Mapping.ary2md.
  def obj2soap(soapKlass, obj, info, map)
    arrayType = getObjType(obj)
    if arrayType.name
      arrayType.namespace ||= RubyTypeNamespace
    else
      arrayType = XSD::AnyTypeName
    end
    param = SOAPArray.new(ValueArrayName, 1, arrayType)
    markMarshalledObj(obj, param)
    obj.each do |var|
      param.add(Mapping._obj2soap(var, map))
    end
    param
  end

  def soap2obj(objKlass, node, info, map)
    obj = createEmptyObject(objKlass)
    markUnmarshalledObj(node, obj)
    node.soap2array(obj) do |elem|
      elem ? Mapping._soap2obj(elem, map) : nil
    end
    return true, obj
  end
end

class TypedArrayFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    arrayType = info[:type] || info[0]
    param = SOAPArray.new(ValueArrayName, 1, arrayType)
    markMarshalledObj(obj, param)
    obj.each do |var|
      param.add(Mapping._obj2soap(var, map))
    end
    param
  end

  def soap2obj(objKlass, node, info, map)
    if node.rank > 1
      return false
    end
    arrayType = info[:type] || info[0]
    unless node.arrayType == arrayType
      return false
    end
    obj = createEmptyObject(objKlass)
    markUnmarshalledObj(node, obj)
    node.soap2array(obj) do |elem|
      elem ? Mapping._soap2obj(elem, map) : nil
    end
    return true, obj
  end
end

class TypedStructFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    type = info[:type] || info[0]
    param = SOAPStruct.new(type )
    markMarshalledObj(obj, param)
    if obj.class <= SOAP::Marshallable
      setiv2soap(param, obj, map)
    else
      setiv2soap(param, obj, map)
    end
    param
  end

  def soap2obj(objKlass, node, info, map)
    type = info[:type] || info[0]
    unless node.type == type
      return false
    end
    obj = createEmptyObject(objKlass)
    markUnmarshalledObj(node, obj)
    setiv2obj(obj, node, map)
    return true, obj
  end
end

MapQName = XSD::QName.new(ApacheSOAPTypeNamespace, 'Map')
class HashFactory_ < Factory
  def obj2soap(soapKlass, obj, info, map)
    if obj.default or
        (obj.respond_to?(:default_proc) and obj.default_proc)
      return nil
    end
    param = SOAPStruct.new(MapQName)
    markMarshalledObj(obj, param)
    obj.each do |key, value|
      elem = SOAPStruct.new
      elem.add("key", Mapping._obj2soap(key, map))
      elem.add("value", Mapping._obj2soap(value, map))
      # ApacheAxis allows only 'item' here.
      param.add("item", elem)
    end
    param
  end

  def soap2obj(objKlass, node, info, map)
    unless node.type == MapQName
      return false
    end
    if node.has_key?('default')
      return false
    end
    obj = createEmptyObject(objKlass)
    markUnmarshalledObj(node, obj)
    node.each do |key, value|
      obj[Mapping._soap2obj(value['key'], map)] =
        Mapping._soap2obj(value['value'], map)
    end
    return true, obj
  end
end


end
end
