require 'GoogleSearch.rb'

require 'soap/rpc/driver'

class GoogleSearchPort < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://api.google.com/search/beta2"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    GoogleSearchResult,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "GoogleSearchResult") }
  )
  MappingRegistry.set(
    ResultElementArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "ResultElement") }
  )
  MappingRegistry.set(
    DirectoryCategoryArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "DirectoryCategory") }
  )
  MappingRegistry.set(
    ResultElement,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "ResultElement") }
  )
  MappingRegistry.set(
    DirectoryCategory,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "DirectoryCategory") }
  )

  Methods = [
    ["doGetCachedPage", "doGetCachedPage",
      [
        [:in, "key", ["::SOAP::SOAPString"]],
        [:in, "url", ["::SOAP::SOAPString"]],
        [:retval, "return", ["::SOAP::SOAPBase64"]]
      ],
      "urn:GoogleSearchAction", "urn:GoogleSearch", :rpc
    ],
    ["doSpellingSuggestion", "doSpellingSuggestion",
      [
        [:in, "key", ["::SOAP::SOAPString"]],
        [:in, "phrase", ["::SOAP::SOAPString"]],
        [:retval, "return", ["::SOAP::SOAPString"]]
      ],
      "urn:GoogleSearchAction", "urn:GoogleSearch", :rpc
    ],
    ["doGoogleSearch", "doGoogleSearch",
      [
        [:in, "key", ["::SOAP::SOAPString"]],
        [:in, "q", ["::SOAP::SOAPString"]],
        [:in, "start", ["::SOAP::SOAPInt"]],
        [:in, "maxResults", ["::SOAP::SOAPInt"]],
        [:in, "filter", ["::SOAP::SOAPBoolean"]],
        [:in, "restrict", ["::SOAP::SOAPString"]],
        [:in, "safeSearch", ["::SOAP::SOAPBoolean"]],
        [:in, "lr", ["::SOAP::SOAPString"]],
        [:in, "ie", ["::SOAP::SOAPString"]],
        [:in, "oe", ["::SOAP::SOAPString"]],
        [:retval, "return", ["GoogleSearchResult", "urn:GoogleSearch", "GoogleSearchResult"]]
      ],
      "urn:GoogleSearchAction", "urn:GoogleSearch", :rpc
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |name_as, name, params, soapaction, namespace, style|
      qname = XSD::QName.new(namespace, name_as)
      if style == :document
        @proxy.add_document_method(soapaction, name, params)
        add_document_method_interface(name, params)
      else
        @proxy.add_rpc_method(qname, soapaction, name, params)
        add_rpc_method_interface(name, params)
      end
      if name_as != name and name_as.capitalize == name.capitalize
        ::SOAP::Mapping.define_singleton_method(self, name_as) do |*arg|
          __send__(name, *arg)
        end
      end
    end
  end
end

