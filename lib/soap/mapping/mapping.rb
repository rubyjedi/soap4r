=begin
SOAP4R - Ruby type mapping utility.
Copyright (C) 2000, 2001, 2003 NAKAMURA Hiroshi.

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
  RubyTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/1.6'
  RubyTypeInstanceNamespace =
    'http://www.ruby-lang.org/xmlns/ruby/type-instance'
  RubyCustomTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/custom'
  ApacheSOAPTypeNamespace = 'http://xml.apache.org/xml-soap'


  # TraverseSupport breaks Thread.current[:SOAPMarshalDataKey].
  module TraverseSupport
    def markMarshalledObj(obj, soapObj)
      Thread.current[:SOAPMarshalDataKey][obj.__id__] = soapObj
    end

    def markUnmarshalledObj(node, obj)
      # node.id is not Object#id but SOAPReference#id
      Thread.current[:SOAPMarshalDataKey][node.id] = obj
    end
  end


  def self.obj2soap(obj, mappingRegistry = nil, type = nil)
    mappingRegistry ||= Mapping::DefaultRegistry
    Thread.current[:SOAPMarshalDataKey] = {}
    soapObj = _obj2soap(obj, mappingRegistry, type)
    Thread.current[:SOAPMarshalDataKey] = nil
    soapObj
  end

  def self.soap2obj(node, mappingRegistry = nil)
    mappingRegistry ||= Mapping::DefaultRegistry
    Thread.current[:SOAPMarshalDataKey] = {}
    obj = _soap2obj(node, mappingRegistry)
    Thread.current[:SOAPMarshalDataKey] = nil
    obj
  end

  def self.ary2soap(ary, typeNamespace = XSD::Namespace,
      typeName = XSD::AnyTypeLiteral, mappingRegistry = nil)
    type = XSD::QName.new(typeNamespace, typeName)
    mappingRegistry ||= Mapping::DefaultRegistry
    soapAry = SOAPArray.new(ValueArrayName, 1, type)
    Thread.current[:SOAPMarshalDataKey] = {}
    ary.each do |ele|
      soapAry.add(_obj2soap(ele, mappingRegistry, type))
    end
    Thread.current[:SOAPMarshalDataKey] = nil
    soapAry
  end

  def self.ary2md(ary, rank, typeNamespace = XSD::Namespace,
      typeName = XSD::AnyTypeLiteral, mappingRegistry = nil)
    type = XSD::QName.new(typeNamespace, typeName)
    mappingRegistry ||= Mapping::DefaultRegistry
    mdAry = SOAPArray.new(ValueArrayName, rank, type)
    Thread.current[:SOAPMarshalDataKey] = {}
    addMDAry(mdAry, ary, [], mappingRegistry)
    Thread.current[:SOAPMarshalDataKey] = nil
    mdAry
  end

  def self.fault2exception(e, mappingRegistry = nil)
    mappingRegistry ||= Mapping::DefaultRegistry
    detail = if e.detail
        soap2obj(e.detail, mappingRegistry) || ""
      else
        ""
      end
    if detail.is_a?(Mapping::SOAPException)
      begin
        raise detail.to_e
      rescue Exception => e2
        detail.set_backtrace(e2)
        raise
      end
    else
      e.detail = detail
      e.set_backtrace(
        if detail.is_a?(Array)
          detail.map! { |s|
            s.sub(/^/, @handler.endPoint + ':')
          }
        else
          [detail.to_s]
        end
     )
      raise
    end
  end

  def self._obj2soap(obj, mappingRegistry, type = nil)
    if referent = Thread.current[:SOAPMarshalDataKey][obj.__id__]
      soapObj = SOAPReference.new
      soapObj.__setobj__(referent)
      soapObj
    else
      mappingRegistry.obj2soap(obj.class, obj, type)
    end
  end

  def self._soap2obj(node, mappingRegistry)
    if node.is_a?(SOAPReference)
      target = node.__getobj__
      # target.id is not Object#id but SOAPReference#id
      if referent = Thread.current[:SOAPMarshalDataKey][target.id]
        return referent
      else
        return _soap2obj(target, mappingRegistry)
      end
    end
    return mappingRegistry.soap2obj(node.class, node)
  end


  # Allow only (Letter | '_') (Letter | Digit | '-' | '_')* here.
  # Caution: '.' is not allowed here.
  # To follow XML spec., it should be NCName.
  #   (denied chars) => .[0-F][0-F]
  #   ex. a.b => a.2eb
  #
  def self.getElementNameFromName(name)
    name.gsub(/([^a-zA-Z0-9:_-]+)/n) {
      '.' << $1.unpack('H2' * $1.size).join('.')
    }.gsub(/::/n, '..')
  end

  def self.getNameFromElementName(name)
    name.gsub(/\.\./n, '::').gsub(/((?:\.[0-9a-fA-F]{2})+)/n) {
      [$1.delete('.')].pack('H*')
    }
  end

  def self.getClassFromName(name)
    if /^[A-Z]/ !~ name
      return nil
    end
    klass = ::Object
    name.split('::').each do |klassStr|
      if klass.const_defined?(klassStr)
        klass = klass.const_get(klassStr)
      else
        return nil
      end
    end
    klass
  end

  def self.createClassType(klass)
    type = Mapping.getClassType(klass)
    type.name ||= Mapping.getElementNameFromName(klass.name)
    type.namespace ||= RubyCustomTypeNamespace
    type
  end

  def self.getClassType(klass)
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

  def self.getObjType(obj)
    name = namespace = nil
    ivars = obj.instance_variables
    if ivars.include?("@typeName")
      name = obj.instance_eval("@typeName")
    end
    if ivars.include?("@typeNamespace")
      namespace = obj.instance_eval("@typeNamespace")
    end
    if !name or !namespace
      getClassType(obj.class)
    else
      XSD::QName.new(namespace, name)
    end
  end

  class << Mapping
  private
    def addMDAry(mdAry, ary, indices, mappingRegistry)
      for idx in 0..(ary.size - 1)
        if ary[idx].is_a?(Array)
          addMDAry(mdAry, ary[idx], indices + [idx], mappingRegistry)
        else
          mdAry[*(indices + [idx])] = _obj2soap(ary[idx], mappingRegistry)
        end
      end
    end
  end
end


end
