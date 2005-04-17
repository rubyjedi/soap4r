require 'xsd/qname'

# {urn:docrpc}echoele
class Echoele
  @@schema_type = "echoele"
  @@schema_ns = "urn:docrpc"
  @@schema_attribute = {"attr_string" => "SOAP::SOAPString", "attr-int" => "SOAP::SOAPInt"}
  @@schema_element = [["struct1", "Echo_struct"], ["struct_2", ["Echo_struct", XSD::QName.new(nil, "struct-2")]]]

  attr_accessor :struct1
  attr_accessor :struct_2

  def attr_attr_string
    (@__soap_attribute ||= {})["attr_string"]
  end

  def attr_attr_string=(value)
    (@__soap_attribute ||= {})["attr_string"] = value
  end

  def attr_attr_int
    (@__soap_attribute ||= {})["attr-int"]
  end

  def attr_attr_int=(value)
    (@__soap_attribute ||= {})["attr-int"] = value
  end

  def initialize(struct1 = nil, struct_2 = nil)
    @struct1 = struct1
    @struct_2 = struct_2
    @__soap_attribute = {}
  end
end

# {urn:docrpc}echo_response
class Echo_response
  @@schema_type = "echo_response"
  @@schema_ns = "urn:docrpc"
  @@schema_attribute = {"attr_string" => "SOAP::SOAPString", "attr-int" => "SOAP::SOAPInt"}
  @@schema_element = [["struct1", "Echo_struct"], ["struct_2", ["Echo_struct", XSD::QName.new(nil, "struct-2")]]]

  attr_accessor :struct1
  attr_accessor :struct_2

  def attr_attr_string
    (@__soap_attribute ||= {})["attr_string"]
  end

  def attr_attr_string=(value)
    (@__soap_attribute ||= {})["attr_string"] = value
  end

  def attr_attr_int
    (@__soap_attribute ||= {})["attr-int"]
  end

  def attr_attr_int=(value)
    (@__soap_attribute ||= {})["attr-int"] = value
  end

  def initialize(struct1 = nil, struct_2 = nil)
    @struct1 = struct1
    @struct_2 = struct_2
    @__soap_attribute = {}
  end
end

# {urn:docrpc}echo_struct
class Echo_struct
  @@schema_type = "echo_struct"
  @@schema_ns = "urn:docrpc"
  @@schema_attribute = {"m_attr" => "SOAP::SOAPString"}
  @@schema_element = [["m_string", "SOAP::SOAPString"], ["m_datetime", "SOAP::SOAPDateTime"]]

  attr_accessor :m_string
  attr_accessor :m_datetime

  def attr_m_attr
    (@__soap_attribute ||= {})["m_attr"]
  end

  def attr_m_attr=(value)
    (@__soap_attribute ||= {})["m_attr"] = value
  end

  def initialize(m_string = nil, m_datetime = nil)
    @m_string = m_string
    @m_datetime = m_datetime
    @__soap_attribute = {}
  end
end
