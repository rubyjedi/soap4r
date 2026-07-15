# encoding: UTF-8
# SOAP4R - SOAP elements library
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/qname'
require 'soap/baseData'
require 'soap/soapversion'


module SOAP


###
## SOAP elements
#
module SOAPEnvelopeElement; end

class SOAPFault < SOAPStruct
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  def faultcode
    self['faultcode']
  end

  def faultstring
    self['faultstring']
  end

  def faultactor
    self['faultactor']
  end

  def detail
    self['detail']
  end

  def faultcode=(rhs)
    self['faultcode'] = rhs
  end

  def faultstring=(rhs)
    self['faultstring'] = rhs
  end

  def faultactor=(rhs)
    self['faultactor'] = rhs
  end

  def detail=(rhs)
    self['detail'] = rhs
  end

  def initialize(faultcode = nil, faultstring = nil, faultactor = nil, detail = nil)
    super(EleFaultName)
    @elename = EleFaultName
    @encodingstyle = EncodingNamespace
    if faultcode
      self.faultcode = faultcode
      self.faultstring = faultstring
      self.faultactor = faultactor
      self.detail = detail
      self.faultcode.elename = EleFaultCodeName if self.faultcode
      self.faultstring.elename = EleFaultStringName if self.faultstring
      self.faultactor.elename = EleFaultActorName if self.faultactor
      self.detail.elename = EleFaultDetailName if self.detail
    end
    faultcode.parent = self if faultcode
    faultstring.parent = self if faultstring
    faultactor.parent = self if faultactor
    detail.parent = self if detail
  end

  def encode(generator, ns, attrs = {})
    Generator.assign_ns(attrs, ns, EnvelopeNamespace)
    Generator.assign_ns(attrs, ns, EncodingNamespace)
    attrs[ns.name(AttrEncodingStyleName)] = EncodingNamespace
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    yield(self.faultcode)
    yield(self.faultstring)
    yield(self.faultactor)
    yield(self.detail) if self.detail
    generator.encode_tag_end(name, true)
  end
end


# The SOAP 1.2 fault shape (env:Fault > Code{Value,Subcode?} +
# Reason{Text}+ + Node? + Role? + Detail?) is structurally different
# enough from SOAP 1.1's flat faultcode/faultstring/faultactor/detail
# (SOAPFault above, left completely untouched) that it gets its own
# class rather than trying to make one class cover both shapes.
#
# Code/Subcode/Reason and their leaf children (Value/Text/Role) are built
# as SOAPElement instances rather than SOAPStruct/SOAPQName: SOAPElement
# defaults its own encodingstyle to LiteralNamespace, which routes
# encoding through LiteralHandler instead of the RPC/Encoded-style
# SOAPHandler -- avoiding a pile of xsi:type/encodingStyle attributes and
# stray namespace declarations that SOAP 1.2 fault content, being plain
# structural XML rather than SOAP-encoded data, has no business carrying.
# SOAPElement's text-content handling also already special-cases QName
# values (used for Value's content, e.g. FaultCode12::Sender) by
# resolving them against the current namespace-to-prefix mapping at
# encode time -- exactly what's needed here, and not something
# SOAPQName's generic path does on its own.
#
# No new decode-dispatch wiring needed despite the nesting: both
# SOAPHandler's and LiteralHandler's decode_parent key struct/element
# children purely by local name (node.elename.name), never by namespace,
# so Code/Subcode/Reason/etc. decode through the exact same generic
# machinery already used for all other body content.
class SOAP12Fault < SOAPStruct
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  # Standard fault-code Values (Sender/Receiver/MustUnderstand/
  # VersionMismatch) always live in the SOAP 1.2 envelope namespace per
  # spec, so those resolve back to a real XSD::QName even after a decode
  # round-trip, where the wire value is just a prefixed string ("env:
  # Sender") with no automatic QName-content resolution in the generic
  # literal-style decode path this reuses (a real, pre-existing gap in
  # this codebase, not something specific to fault codes -- no QName-
  # typed element content resolves its prefix back to a namespace
  # anywhere today without an explicit type-driven decode path). Custom
  # Subcodes can live in arbitrary app namespaces, so code_subcode can't
  # apply the same trick; it returns the resolved QName only when never
  # serialized (same-process construction), and the raw wire string
  # ("n1:BadArgument") after a real decode.
  STANDARD_FAULT_CODE_LOCAL_NAMES = {
    'Sender' => FaultCode12::Sender,
    'Receiver' => FaultCode12::Receiver,
    'MustUnderstand' => FaultCode12::MustUnderstand,
    'VersionMismatch' => FaultCode12::VersionMismatch
  }

  def code_value
    v = self['Code'] && self['Code']['Value']
    return nil unless v
    data = v.data
    return data unless data.is_a?(String)
    STANDARD_FAULT_CODE_LOCAL_NAMES[data.sub(/\A[^:]+:/, '')] || data
  end

  def code_subcode
    v = self['Code'] && self['Code']['Subcode'] && self['Code']['Subcode']['Value']
    v && v.data
  end

  def reason_text
    v = self['Reason'] && self['Reason']['Text']
    v && v.data
  end

  def node
    v = self['Node']
    v && v.data
  end

  def role
    v = self['Role']
    v && v.data
  end

  def detail
    self['Detail']
  end

  def detail=(rhs)
    self['Detail'] = rhs
  end

  # code_value/code_subcode are XSD::QName (see FaultCode12::Sender etc);
  # reason_text/node/role are plain strings; detail is any SOAP/OM node.
  def initialize(code_value = nil, reason_text = nil, code_subcode = nil,
                  role = nil, detail = nil, reason_lang = 'en')
    ns_uri = SOAPVersion1_2.envelope_namespace
    super(XSD::QName.new(ns_uri, EleFault))
    @elename = XSD::QName.new(ns_uri, EleFault)
    @encodingstyle = LiteralNamespace
    return unless code_value

    code = SOAPElement.new(XSD::QName.new(ns_uri, 'Code'))
    code.add(SOAPElement.new(XSD::QName.new(ns_uri, 'Value'), code_value))
    if code_subcode
      subcode = SOAPElement.new(XSD::QName.new(ns_uri, 'Subcode'))
      subcode.add(SOAPElement.new(XSD::QName.new(ns_uri, 'Value'), code_subcode))
      code.add(subcode)
    end
    self.add('Code', code)

    reason = SOAPElement.new(XSD::QName.new(ns_uri, 'Reason'))
    text = SOAPElement.new(XSD::QName.new(ns_uri, 'Text'), reason_text)
    text.extraattr[XSD::QName.new(XSD::NS::Namespace, 'lang')] = reason_lang
    reason.add(text)
    self.add('Reason', reason)

    if role
      self.add('Role', SOAPElement.new(XSD::QName.new(ns_uri, 'Role'), role))
    end
    if detail
      detail.elename = XSD::QName.new(ns_uri, 'Detail') if detail.respond_to?(:elename=)
      self.add('Detail', detail)
    end
  end

  def encode(generator, ns, attrs = {})
    Generator.assign_ns(attrs, ns, SOAPVersion1_2.envelope_namespace)
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    yield(self['Code'])
    yield(self['Reason'])
    yield(self['Node']) if self['Node']
    yield(self['Role']) if self['Role']
    yield(self['Detail']) if self['Detail']
    generator.encode_tag_end(name, true)
  end
end


class SOAPBody < SOAPStruct
  include SOAPEnvelopeElement

  attr_reader :is_fault

  def initialize(data = nil, is_fault = false, soap_version = SOAPVersion1_1)
    super(nil)
    @elename = XSD::QName.new(soap_version.envelope_namespace, EleBody)
    @encodingstyle = nil
    if data
      if data.respond_to?(:to_xmlpart)
        data = SOAP::SOAPRawData.new(data)
      elsif defined?(::REXML) && defined?(::REXML::Element) && data.is_a?(::REXML::Element)
        data = SOAP::SOAPRawData.new(SOAP::SOAPREXMLElementWrap.new(data))
      end
      if data.respond_to?(:elename)
        add(data.elename.name, data)
      else
        data.to_a.each do |datum|
          add(datum.elename.name, datum)
        end
      end
    end
    @is_fault = is_fault
  end

  def encode(generator, ns, attrs = {})
    # extraattr can hold XSD::QName-keyed custom attributes (e.g. a
    # wsu:Id for a WS-Security signature Reference to target) -- unlike
    # an ordinary SOAPElement (which serializes itself via #to_xmlpart, a
    # self-contained mini-serializer with its own locally-scoped prefix
    # assignment), SOAPBody goes through the shared, document-wide `ns`
    # prefix registry here, so any QName-keyed attrs need the same
    # explicit assign-then-rekey treatment SOAPFault#encode already does
    # above for its own two hardcoded namespaces -- just generalized to
    # whatever namespace(s) actually show up here. A no-op when extraattr
    # has no QName keys (the common case), so existing behavior for
    # every caller that's never needed this is unaffected.
    #
    # `attrs` here (via encode_element in generator.rb) *is* obj.extraattr
    # itself, not a copy -- rekeying in place would permanently replace
    # the QName key with a resolved string on the object being marshaled,
    # so a second #marshal of the same envelope (e.g. WS-Security's own
    # preview-then-real two-pass signing, see lib/soap/wssecurity.rb)
    # would silently stop re-registering the namespace the second time,
    # possibly with a fresh `ns` registry assigning a different prefix.
    # Marshaling must never mutate the object it's marshaling. Build a
    # fresh hash instead.
    qname_keys = attrs.keys.select { |key| key.is_a?(XSD::QName) }
    unless qname_keys.empty?
      attrs = attrs.dup
      qname_keys.each do |key|
        Generator.assign_ns(attrs, ns, key.namespace) if key.namespace
      end
      qname_keys.each do |key|
        attrs[ns.name(key)] = attrs.delete(key)
      end
    end
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    @data.each do |data|
      yield(data)
    end
    generator.encode_tag_end(name, @data.size > 0)
  end

  def root_node
    @data.each do |node|
      if node.root == 1
	return node
      end
    end
    # No specified root...
    @data.each do |node|
      if node.root != 0
	return node
      end
    end
    raise Parser::FormatDecodeError.new('no root element')
  end
end


class SOAPHeaderItem < XSD::NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  attr_accessor :element
  attr_accessor :mustunderstand
  attr_accessor :encodingstyle
  attr_accessor :actor
  attr_accessor :relay

  def initialize(element, mustunderstand = true, encodingstyle = nil, actor = nil,
                  relay = nil, soap_version = SOAPVersion1_1)
    super()
    @type = nil
    @element = element
    @mustunderstand = mustunderstand
    @encodingstyle = encodingstyle
    @actor = actor
    @relay = relay
    @soap_version = soap_version
    element.parent = self if element
    element.qualified = true
  end

  def encode(generator, ns, attrs = {})
    attrs.each do |key, value|
      @element.extraattr[key] = value
    end
    # to remove mustUnderstand attribute, set it to nil
    unless @mustunderstand.nil?
      @element.extraattr[@soap_version.mustunderstand_attr_name] =
        (@mustunderstand ? '1' : '0')
    end
    if @encodingstyle
      @element.extraattr[AttrEncodingStyleName] = @encodingstyle
    end
    unless @element.encodingstyle
      @element.encodingstyle = @encodingstyle
    end
    if @actor
      @element.extraattr[@soap_version.role_attr_name] = @actor
    end
    # relay has no SOAP 1.1 equivalent -- @soap_version.relay_attr_name is
    # nil there, so this is a no-op unless actually running under 1.2.
    unless @relay.nil? || @soap_version.relay_attr_name.nil?
      @element.extraattr[@soap_version.relay_attr_name] = (@relay ? 'true' : 'false')
    end
    yield(@element)
  end
end


class SOAPHeader < SOAPStruct
  include SOAPEnvelopeElement

  attr_writer :force_encode
  attr_reader :soap_version

  def initialize(soap_version = SOAPVersion1_1)
    super(nil)
    @elename = XSD::QName.new(soap_version.envelope_namespace, EleHeader)
    @encodingstyle = nil
    @force_encode = false
    @soap_version = soap_version
  end

  def encode(generator, ns, attrs = {})
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    @data.each do |data|
      yield(data)
    end
    generator.encode_tag_end(name, @data.size > 0)
  end

  def add(name, value)
    actor = value.extraattr[@soap_version.role_attr_name]
    mu = value.extraattr[@soap_version.mustunderstand_attr_name]
    encstyle = value.extraattr[AttrEncodingStyleName]
    mu_value = mu.nil? ? nil : (mu == '1' || mu == 'true')
    relay = @soap_version.relay_attr_name && value.extraattr[@soap_version.relay_attr_name]
    relay_value = relay.nil? ? nil : (relay == 'true' || relay == '1')
    # to remove mustUnderstand attribute, set it to nil
    item = SOAPHeaderItem.new(value, mu_value, encstyle, actor, relay_value, @soap_version)
    super(name, item)
  end

  def length
    @data.length
  end
  alias size length

  def encode?
    @force_encode or length > 0
  end
end


class SOAPEnvelope < XSD::NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype

  attr_reader :header
  attr_reader :body
  attr_reader :external_content

  def initialize(header = nil, body = nil, soap_version = SOAPVersion1_1)
    super()
    @type = nil
    @elename = XSD::QName.new(soap_version.envelope_namespace, EleEnvelope)
    @encodingstyle = nil
    @header = header
    @body = body
    @external_content = {}
    header.parent = self if header
    body.parent = self if body
  end

  def header=(header)
    header.parent = self
    @header = header
  end

  def body=(body)
    body.parent = self
    @body = body
  end

  def encode(generator, ns, attrs = {})
    Generator.assign_ns(attrs, ns, elename.namespace)
    name = ns.name(@elename)
    generator.encode_tag(name, attrs)
    yield(@header) if @header and @header.encode?
    yield(@body)
    generator.encode_tag_end(name, true)
  end

  def to_ary
    [header, body]
  end
end


end
