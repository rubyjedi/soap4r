=begin
SOAP4R - WSDL mapping registry.
Copyright (C) 2000, 2001, 2002, 2003  NAKAMURA, Hiroshi.

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
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'


module SOAP
module Mapping


class WSDLRegistry
  include TraverseSupport

  attr_reader :complextypes

  def initialize(complextypes, config = {})
    @complextypes = complextypes
    @config = config
    @excn_handler_obj2soap = nil
  end

  def obj2soap(klass, obj, type_qname)
    soap_obj = nil
    if obj.nil?
      soap_obj = SOAPNil.new
    elsif obj.is_a?(SOAPBasetype)
      soap_obj = obj
    elsif obj.is_a?(SOAPStruct) && (type = @complextypes[obj.type])
      soap_obj = obj
      mark_marshalled_obj(obj, soap_obj)
      elements2soap(obj, soap_obj, type.content.elements)
    elsif obj.is_a?(SOAPArray) && (type = @complextypes[obj.type])
      contenttype = type.child_type
      soap_obj = obj
      mark_marshalled_obj(obj, soap_obj)
      obj.replace do |ele|
        Mapping._obj2soap(ele, self, contenttype)
      end
    elsif (type = @complextypes[type_qname])
      case type.compoundtype
      when :TYPE_STRUCT
        soap_obj = struct2soap(obj, type_qname, type)
      when :TYPE_ARRAY
        soap_obj = array2soap(obj, type_qname, type)
      end
    elsif (type = TypeMap[type_qname])
      soap_obj = base2soap(obj, type)
    end
    return soap_obj if soap_obj

    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
    end
    return soap_obj if soap_obj

    raise MappingError.new("Cannot map #{ klass.name } to SOAP/OM.")
  end

  def obj2ele(obj, type_qname)
    ele = nil
    type = @complextypes[type_qname]
    if obj.nil?
      ele = SOAPElement.new(type_qname)
    elsif type
      ele = struct2ele(obj, type_qname, type)
    end
    return ele if ele
    raise MappingError.new("Cannot map #{ type_qname } to XML element.")
  end

  def soap2obj(klass, node)
    raise RuntimeError.new("#{ self } is for obj2soap only.")
  end

  def excn_handler_obj2soap=(handler)
    @excn_handler_obj2soap = handler
  end

private

  def base2soap(obj, type)
    soap_obj = nil
    if type <= XSD::XSDString
      soap_obj = type.new(Charset.is_ces(obj, $KCODE) ?
        Charset.encoding_conv(obj, $KCODE, Charset.encoding) : obj)
      mark_marshalled_obj(obj, soap_obj)
    else
      soap_obj = type.new(obj)
    end
    soap_obj
  end

  def struct2soap(obj, type_qname, type)
    soap_obj = SOAPStruct.new(type_qname)
    mark_marshalled_obj(obj, soap_obj)
    elements2soap(obj, soap_obj, type.content.elements)
    soap_obj
  end

  def array2soap(obj, soap_obj, type)
    contenttype = type.child_type
    soap_obj = SOAPArray.new(ValueArrayName, 1, contenttype)
    mark_marshalled_obj(obj, soap_obj)
    obj.each do |item|
      soap_obj.add(Mapping._obj2soap(item, self, contenttype))
    end
    soap_obj
  end

  def elements2soap(obj, soap_obj, elements)
    elements.each do |element|
      name = element.name
      child_obj = obj.instance_eval('@' << name)
      soap_obj.add(name, Mapping._obj2soap(child_obj, self, element.type))
    end
  end

  def struct2ele(obj, type_qname, type)
    ele = SOAPElement.new(type_qname)
    elements2ele(obj, ele, type.content.elements)
    ele
  end

  def elements2ele(obj, ele, elements)
    elements.each do |element|
      name = element.name
      child_obj = obj.instance_eval('@' << name)
      ele.add(obj2ele(child_obj, element.type))
    end
  end
end


end
end
