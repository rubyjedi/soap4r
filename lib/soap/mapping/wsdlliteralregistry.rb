# SOAP4R - WSDL literal mapping registry.
# Copyright (C) 2004-2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/literalregistry'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'
require 'xsd/namedelements'


module SOAP
module Mapping


class WSDLLiteralRegistry < LiteralRegistry
  attr_reader :definedelements
  attr_reader :definedtypes

  def initialize(definedtypes = XSD::NamedElements::Empty,
      definedelements = XSD::NamedElements::Empty)
    super()
    @definedtypes = definedtypes
    @definedelements = definedelements
  end

  def obj2soap(obj, qname)
    soap_obj = nil
    if obj.is_a?(SOAPElement)
      soap_obj = obj
    elsif eledef = @definedelements[qname]
      soap_obj = obj2elesoap(obj, eledef)
    elsif type = @definedtypes[qname]
      soap_obj = obj2typesoap(obj, type, true)
    else
      soap_obj = any2soap(obj, qname)
    end
    return soap_obj if soap_obj
    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping.obj2soap(yield_obj, nil, nil, MAPPING_OPT)
      }
      return soap_obj if soap_obj
    end
    raise MappingError.new("cannot map #{obj.class.name} as #{qname}")
  end

  # node should be a SOAPElement
  def soap2obj(node, obj_class = nil)
    # obj_class is given when rpc/literal service.  but ignored for now.
    begin
      return any2obj(node)
    rescue MappingError
    end
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping.soap2obj(yield_node, nil, nil, MAPPING_OPT)
	  }
      rescue Exception
      end
    end
    if node.respond_to?(:type)
      raise MappingError.new("cannot map #{node.type.name} to Ruby object")
    else
      raise MappingError.new("cannot map #{node.elename.name} to Ruby object")
    end
  end

private

  def obj2elesoap(obj, eledef)
    ele = nil
    qualified = (eledef.elementform == 'qualified')
    if eledef.type
      if type = @definedtypes[eledef.type]
        ele = obj2typesoap(obj, type, qualified)
      elsif type = TypeMap[eledef.type]
        ele = base2soap(obj, type)
      else
        raise MappingError.new("cannot find type #{eledef.type}")
      end
    elsif eledef.local_complextype
      ele = obj2typesoap(obj, eledef.local_complextype, qualified)
    elsif eledef.local_simpletype
      ele = obj2typesoap(obj, eledef.local_simpletype, qualified)
    else
      raise MappingError.new('illegal schema?')
    end
    ele.elename = eledef.name
    ele
  end

  def obj2typesoap(obj, type, qualified)
    ele = nil
    if type.is_a?(::WSDL::XMLSchema::SimpleType)
      ele = simpleobj2soap(obj, type)
    elsif type.simplecontent
      ele = simpleobj2soap(obj, type.simplecontent)
    else
      ele = complexobj2soap(obj, type, qualified)
    end
    add_attributes2soap(obj, ele)
    ele
  end

  def simpleobj2soap(obj, type)
    type.check_lexical_format(obj)
    return SOAPNil.new if obj.nil?      # TODO: check nillable.
    if type.base
      ele = base2soap(obj, TypeMap[type.base])
    elsif type.list
      value = obj.is_a?(Array) ? obj.join(" ") : obj.to_s
      ele = base2soap(value, SOAP::SOAPString)
    else
      raise MappingError.new("unsupported simpleType: #{type}")
    end
    ele
  end

  def complexobj2soap(obj, type, qualified)
    ele = SOAPElement.new(type.name)
    ele.qualified = qualified
    if type.choice?
      complexobj2choicesoap(obj, ele, type)
    else
      complexobj2sequencesoap(obj, ele, type)
    end
  end

  def complexobj2sequencesoap(obj, ele, type)
    elements = type.elements
    any = nil
    if type.have_any?
      any = Mapping.get_attributes_for_any(obj, elements)
    end
    elements.each do |child_ele|
      case child_ele
      when WSDL::XMLSchema::Any
        if any
          SOAPElement.from_objs(any).each do |child|
            ele.add(child)
          end
        end
      when WSDL::XMLSchema::Element
        complexobj2soapchildren(obj, ele, child_ele)
      when WSDL::XMLSchema::Sequence
        complexobj2sequencesoap(obj, child_ele, type)
      when WSDL::XMLSchema::Choice
        complexobj2choicesoap(obj, child_ele, type)
      else
        raise MappingError.new("unknown type: #{child_ele}")
      end
    end
    ele
  end

  def complexobj2choicesoap(obj, ele, type)
    elements = type.elements
    any = nil
    if type.have_any?
      raise MappingError.new(
        "<any/> in <choice/> is not supported: #{ele.name.name}")
    end
    elements.each do |child_ele|
      break if complexobj2soapchildren(obj, ele, child_ele, true)
    end
    ele
  end

  def complexobj2soapchildren(obj, ele, child_ele, allow_nil_value = false)
    if child_ele.map_as_array?
      complexobj2soapchildren_array(obj, ele, child_ele, allow_nil_value)
    else
      complexobj2soapchildren_single(obj, ele, child_ele, allow_nil_value)
    end
  end

  def complexobj2soapchildren_array(obj, ele, child_ele, allow_nil_value)
    child = Mapping.get_attribute(obj, child_ele.name.name)
    if child.nil? and obj.respond_to?(:each)
      child = obj
    end
    if child.nil?
      return false if allow_nil_value
      if child_soap = nil2soap(child_ele)
        ele.add(child_soap)
        return true
      else
        return false
      end
    end
    unless child.respond_to?(:each)
      return false
    end
    child.each do |item|
      if item.is_a?(SOAPElement)
        ele.add(item)
      else
        child_soap = obj2elesoap(item, child_ele)
        ele.add(child_soap)
      end
    end
    true
  end

  def complexobj2soapchildren_single(obj, ele, child_ele, allow_nil_value)
    child = Mapping.get_attribute(obj, child_ele.name.name)
    case child
    when NilClass
      return false if allow_nil_value
      if child_soap = nil2soap(child_ele)
        ele.add(child_soap)
        true
      else
        false
      end
    when SOAPElement
      ele.add(child)
      true
    else
      child_soap = obj2elesoap(child, child_ele)
      ele.add(child_soap)
      true
    end
  end

  def nil2soap(ele)
    if ele.nillable
      obj2elesoap(nil, ele)     # add an empty element
    elsif Integer(ele.minoccurs) == 0
      nil       # intends no element
    else
      raise MappingError.new("nil not allowed: #{ele.name.name}")
    end
  end
end


end
end
