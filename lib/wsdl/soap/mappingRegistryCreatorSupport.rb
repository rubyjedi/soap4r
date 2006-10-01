# WSDL4R - Creating MappingRegistry support.
# Copyright (C) 2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/soap/classDefCreatorSupport'


module WSDL
module SOAP


module MappingRegistryCreatorSupport
  include ClassDefCreatorSupport
  include XSD::CodeGen

  def dump_schema_element_definition(definition, indent = 0)
    return '[]' if definition.empty?
    sp = ' ' * indent
    if definition[0] == :choice
      definition.shift
      "[ :choice,\n" +
        dump_schema_element(definition, indent + 2) + "\n" + sp + "]"
    elsif definition[0].is_a?(::Array)
      "[\n" +
        dump_schema_element(definition, indent + 2) + "\n" + sp + "]"
    else
      varname, name, type = definition
      '[' +
        (
          if name
            varname.dump + ', [' + ndq(type) + ', ' + dqname(name) + ']'
          else
            varname.dump + ', ' + ndq(type)
          end
        ) + ']'
    end
  end

  def dump_schema_element(schema_element, indent = 0)
    sp = ' ' * indent
    delimiter = ",\n" + sp
    sp + schema_element.collect { |definition|
      dump_schema_element_definition(definition, indent)
    }.join(delimiter)
  end

  def parse_elements(elements, base_namespace)
    schema_element = []
    any = false
    elements.each do |element|
      case element
      when XMLSchema::Any
        # only 1 <any/> is allowed for now.
        raise RuntimeError.new("duplicated 'any'") if any
        any = true
        varname = 'any' # not used
        eleqname = XSD::AnyTypeName
        type = nil
        schema_element << [varname, eleqname, type]
      when XMLSchema::Element
        if element.type == XSD::AnyTypeName
          type = nil
        elsif klass = element_basetype(element)
          type = klass.name
        elsif element.type
          type = create_class_name(element.type, @modulepath)
        elsif element.ref
          type = create_class_name(element.ref, @modulepath)
        else
          type = nil      # means anyType.
          # do we define a class for local complexType from it's name?
          #   type = create_class_name(element.name, @modulepath)
          # <element>
          #   <complexType>
          #     <seq...>
          #   </complexType>
          # </element>
        end
        name = name_element(element).name
        varname = safevarname(name)
        if element.map_as_array?
          if type
            type << '[]'
          else
            type = '[]'
          end
        end
        # nil means @@schema_ns + varname
        eleqname = element.name || element.ref
        if eleqname && varname == name && eleqname.namespace == base_namespace
          eleqname = nil
        end
        schema_element << [varname, eleqname, type]
      when WSDL::XMLSchema::Sequence
        child_schema_element = parse_elements(element.elements, base_namespace)
        schema_element << child_schema_element
      when WSDL::XMLSchema::Choice
        child_schema_element = parse_elements(element.elements, base_namespace)
        child_schema_element.unshift(:choice)
        schema_element << child_schema_element
      else
        raise RuntimeError.new("unknown type: #{element}")
      end
    end
    schema_element
  end

  def element_basetype(ele)
    if klass = basetype_class(ele.type)
      klass
    elsif ele.local_simpletype
      basetype_class(ele.local_simpletype.base)
    else
      nil
    end
  end

  def attribute_basetype(attr)
    if klass = basetype_class(attr.type)
      klass
    elsif attr.local_simpletype
      basetype_class(attr.local_simpletype.base)
    else
      nil
    end
  end

  def basetype_class(type)
    return nil if type.nil?
    if simpletype = @simpletypes[type]
      basetype_mapped_class(simpletype.base)
    else
      basetype_mapped_class(type)
    end
  end

  def define_attribute(attributes)
    schema_attribute = []
    attributes.each do |attribute|
      name = name_attribute(attribute)
      if klass = attribute_basetype(attribute)
        type = klass.name
      else
        warn("unresolved attribute type #{attribute.type} for #{name}")
        type = nil
      end
      schema_attribute << [name, type]
    end
    "{\n    " +
      schema_attribute.collect { |name, type|
        dqname(name) + ' => ' + ndq(type)
      }.join(",\n    ") +
    "\n  }"
  end

  def name_element(element)
    return element.name if element.name 
    return element.ref if element.ref
    raise RuntimeError.new("cannot define name of #{element}")
  end

  def name_attribute(attribute)
    return attribute.name if attribute.name 
    return attribute.ref if attribute.ref
    raise RuntimeError.new("cannot define name of #{attribute}")
  end

  def dump_entry(regname, var)
    "#{regname}.register(\n  " +
      [
        dump_entry_item(var, :class),
        dump_entry_item(var, :soap_class),
        dump_entry_item(var, :schema_ns, true),
        dump_entry_item(var, :schema_name, true),
        dump_entry_item(var, :schema_type, true),
        dump_entry_item(var, :schema_qualified),
        dump_entry_item(var, :schema_element),
        dump_entry_item(var, :schema_attribute)
      ].compact.join(",\n  ") +
    "\n)\n"
  end

  def dump_entry_item(var, key, as_string = false)
    if var.key?(key)
      if as_string
        ":#{key} => #{ndq(var[key])}"
      else
        ":#{key} => #{var[key]}"
      end
    else
      nil
    end
  end

  def dump_simpletypedef(qname, simpletype)
    if simpletype.restriction
      dump_simpletypedef_restriction(qname, simpletype)
    elsif simpletype.list
      dump_simpletypedef_list(qname, simpletype)
    else
      raise RuntimeError.new("unknown kind of simpletype: #{simpletype}")
    end
  end

  def dump_simpletypedef_restriction(qname, typedef)
    restriction = typedef.restriction
    if restriction.enumeration.empty?
      # not supported.  minlength?
      return nil
    end
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    var[:schema_ns] = qname.namespace
    if typedef.name.nil?
      var[:schema_type] = nil
    else
      var[:schema_type] = qname.name
    end
    dump_entry(@varname, var)
  end

  def dump_simpletypedef_list(qname, typedef)
    nil
  end
end


end
end
