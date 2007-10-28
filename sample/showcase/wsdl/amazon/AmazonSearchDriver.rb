require 'AmazonSearch.rb'

require 'soap/rpc/driver'

class AmazonSearchPort < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://soap.amazon.com/onca/soap3"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    KeywordRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "KeywordRequest") }
  )
  MappingRegistry.set(
    ProductInfo,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ProductInfo") }
  )
  MappingRegistry.set(
    DetailsArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "Details") }
  )
  MappingRegistry.set(
    TextStreamRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "TextStreamRequest") }
  )
  MappingRegistry.set(
    PowerRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "PowerRequest") }
  )
  MappingRegistry.set(
    BrowseNodeRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "BrowseNodeRequest") }
  )
  MappingRegistry.set(
    AsinRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "AsinRequest") }
  )
  MappingRegistry.set(
    BlendedRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "BlendedRequest") }
  )
  MappingRegistry.set(
    ProductLineArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ProductLine") }
  )
  MappingRegistry.set(
    UpcRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "UpcRequest") }
  )
  MappingRegistry.set(
    SkuRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SkuRequest") }
  )
  MappingRegistry.set(
    AuthorRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "AuthorRequest") }
  )
  MappingRegistry.set(
    ArtistRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ArtistRequest") }
  )
  MappingRegistry.set(
    ActorRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ActorRequest") }
  )
  MappingRegistry.set(
    ManufacturerRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ManufacturerRequest") }
  )
  MappingRegistry.set(
    DirectorRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "DirectorRequest") }
  )
  MappingRegistry.set(
    ListManiaRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ListManiaRequest") }
  )
  MappingRegistry.set(
    WishlistRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "WishlistRequest") }
  )
  MappingRegistry.set(
    ExchangeRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ExchangeRequest") }
  )
  MappingRegistry.set(
    ListingProductDetails,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ListingProductDetails") }
  )
  MappingRegistry.set(
    MarketplaceRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "MarketplaceRequest") }
  )
  MappingRegistry.set(
    MarketplaceSearch,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "MarketplaceSearch") }
  )
  MappingRegistry.set(
    MarketplaceSearchDetailsArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "MarketplaceSearchDetails") }
  )
  MappingRegistry.set(
    SellerProfileRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerProfileRequest") }
  )
  MappingRegistry.set(
    SellerProfile,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerProfile") }
  )
  MappingRegistry.set(
    SellerProfileDetailsArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerProfileDetails") }
  )
  MappingRegistry.set(
    SellerRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerRequest") }
  )
  MappingRegistry.set(
    SellerSearch,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerSearch") }
  )
  MappingRegistry.set(
    SellerSearchDetailsArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerSearchDetails") }
  )
  MappingRegistry.set(
    SimilarityRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SimilarityRequest") }
  )
  MappingRegistry.set(
    GetShoppingCartRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "GetShoppingCartRequest") }
  )
  MappingRegistry.set(
    ShoppingCart,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ShoppingCart") }
  )
  MappingRegistry.set(
    ItemArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "Item") }
  )
  MappingRegistry.set(
    SimilarProductsArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    ClearShoppingCartRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ClearShoppingCartRequest") }
  )
  MappingRegistry.set(
    AddShoppingCartItemsRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "AddShoppingCartItemsRequest") }
  )
  MappingRegistry.set(
    AddItemArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "AddItem") }
  )
  MappingRegistry.set(
    RemoveShoppingCartItemsRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "RemoveShoppingCartItemsRequest") }
  )
  MappingRegistry.set(
    ItemIdArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    ModifyShoppingCartItemsRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ModifyShoppingCartItemsRequest") }
  )
  MappingRegistry.set(
    ItemQuantityArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ItemQuantity") }
  )
  MappingRegistry.set(
    GetTransactionDetailsRequest,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "GetTransactionDetailsRequest") }
  )
  MappingRegistry.set(
    OrderIdArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    GetTransactionDetailsResponse,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "GetTransactionDetailsResponse") }
  )
  MappingRegistry.set(
    ShortSummaryArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ShortSummary") }
  )
  MappingRegistry.set(
    Details,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "Details") }
  )
  MappingRegistry.set(
    ProductLine,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ProductLine") }
  )
  MappingRegistry.set(
    MarketplaceSearchDetails,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "MarketplaceSearchDetails") }
  )
  MappingRegistry.set(
    SellerProfileDetails,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerProfileDetails") }
  )
  MappingRegistry.set(
    SellerSearchDetails,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "SellerSearchDetails") }
  )
  MappingRegistry.set(
    Item,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "Item") }
  )
  MappingRegistry.set(
    AddItem,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "AddItem") }
  )
  MappingRegistry.set(
    ItemQuantity,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ItemQuantity") }
  )
  MappingRegistry.set(
    ShortSummary,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://soap.amazon.com", "ShortSummary") }
  )

  Methods = [
    ["KeywordSearchRequest", "keywordSearchRequest",
      [
        [:in, "KeywordSearchRequest", ["KeywordRequest", "http://soap.amazon.com", "KeywordRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["TextStreamSearchRequest", "textStreamSearchRequest",
      [
        [:in, "TextStreamSearchRequest", ["TextStreamRequest", "http://soap.amazon.com", "TextStreamRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["PowerSearchRequest", "powerSearchRequest",
      [
        [:in, "PowerSearchRequest", ["PowerRequest", "http://soap.amazon.com", "PowerRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["BrowseNodeSearchRequest", "browseNodeSearchRequest",
      [
        [:in, "BrowseNodeSearchRequest", ["BrowseNodeRequest", "http://soap.amazon.com", "BrowseNodeRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["AsinSearchRequest", "asinSearchRequest",
      [
        [:in, "AsinSearchRequest", ["AsinRequest", "http://soap.amazon.com", "AsinRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["BlendedSearchRequest", "blendedSearchRequest",
      [
        [:in, "BlendedSearchRequest", ["BlendedRequest", "http://soap.amazon.com", "BlendedRequest"]],
        [:retval, "return", ["ProductLine[]", "http://soap.amazon.com", "ProductLine"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["UpcSearchRequest", "upcSearchRequest",
      [
        [:in, "UpcSearchRequest", ["UpcRequest", "http://soap.amazon.com", "UpcRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["SkuSearchRequest", "skuSearchRequest",
      [
        [:in, "SkuSearchRequest", ["SkuRequest", "http://soap.amazon.com", "SkuRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["AuthorSearchRequest", "authorSearchRequest",
      [
        [:in, "AuthorSearchRequest", ["AuthorRequest", "http://soap.amazon.com", "AuthorRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ArtistSearchRequest", "artistSearchRequest",
      [
        [:in, "ArtistSearchRequest", ["ArtistRequest", "http://soap.amazon.com", "ArtistRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ActorSearchRequest", "actorSearchRequest",
      [
        [:in, "ActorSearchRequest", ["ActorRequest", "http://soap.amazon.com", "ActorRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ManufacturerSearchRequest", "manufacturerSearchRequest",
      [
        [:in, "ManufacturerSearchRequest", ["ManufacturerRequest", "http://soap.amazon.com", "ManufacturerRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["DirectorSearchRequest", "directorSearchRequest",
      [
        [:in, "DirectorSearchRequest", ["DirectorRequest", "http://soap.amazon.com", "DirectorRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ListManiaSearchRequest", "listManiaSearchRequest",
      [
        [:in, "ListManiaSearchRequest", ["ListManiaRequest", "http://soap.amazon.com", "ListManiaRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["WishlistSearchRequest", "wishlistSearchRequest",
      [
        [:in, "WishlistSearchRequest", ["WishlistRequest", "http://soap.amazon.com", "WishlistRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ExchangeSearchRequest", "exchangeSearchRequest",
      [
        [:in, "ExchangeSearchRequest", ["ExchangeRequest", "http://soap.amazon.com", "ExchangeRequest"]],
        [:retval, "return", ["ListingProductDetails", "http://soap.amazon.com", "ListingProductDetails"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["MarketplaceSearchRequest", "marketplaceSearchRequest",
      [
        [:in, "MarketplaceSearchRequest", ["MarketplaceRequest", "http://soap.amazon.com", "MarketplaceRequest"]],
        [:retval, "return", ["MarketplaceSearch", "http://soap.amazon.com", "MarketplaceSearch"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["SellerProfileSearchRequest", "sellerProfileSearchRequest",
      [
        [:in, "SellerProfileSearchRequest", ["SellerProfileRequest", "http://soap.amazon.com", "SellerProfileRequest"]],
        [:retval, "return", ["SellerProfile", "http://soap.amazon.com", "SellerProfile"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["SellerSearchRequest", "sellerSearchRequest",
      [
        [:in, "SellerSearchRequest", ["SellerRequest", "http://soap.amazon.com", "SellerRequest"]],
        [:retval, "return", ["SellerSearch", "http://soap.amazon.com", "SellerSearch"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["SimilaritySearchRequest", "similaritySearchRequest",
      [
        [:in, "SimilaritySearchRequest", ["SimilarityRequest", "http://soap.amazon.com", "SimilarityRequest"]],
        [:retval, "return", ["ProductInfo", "http://soap.amazon.com", "ProductInfo"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["GetShoppingCartRequest", "getShoppingCartRequest",
      [
        [:in, "GetShoppingCartRequest", ["GetShoppingCartRequest", "http://soap.amazon.com", "GetShoppingCartRequest"]],
        [:retval, "ShoppingCart", ["ShoppingCart", "http://soap.amazon.com", "ShoppingCart"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ClearShoppingCartRequest", "clearShoppingCartRequest",
      [
        [:in, "ClearShoppingCartRequest", ["ClearShoppingCartRequest", "http://soap.amazon.com", "ClearShoppingCartRequest"]],
        [:retval, "ShoppingCart", ["ShoppingCart", "http://soap.amazon.com", "ShoppingCart"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["AddShoppingCartItemsRequest", "addShoppingCartItemsRequest",
      [
        [:in, "AddShoppingCartItemsRequest", ["AddShoppingCartItemsRequest", "http://soap.amazon.com", "AddShoppingCartItemsRequest"]],
        [:retval, "ShoppingCart", ["ShoppingCart", "http://soap.amazon.com", "ShoppingCart"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["RemoveShoppingCartItemsRequest", "removeShoppingCartItemsRequest",
      [
        [:in, "RemoveShoppingCartItemsRequest", ["RemoveShoppingCartItemsRequest", "http://soap.amazon.com", "RemoveShoppingCartItemsRequest"]],
        [:retval, "ShoppingCart", ["ShoppingCart", "http://soap.amazon.com", "ShoppingCart"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["ModifyShoppingCartItemsRequest", "modifyShoppingCartItemsRequest",
      [
        [:in, "ModifyShoppingCartItemsRequest", ["ModifyShoppingCartItemsRequest", "http://soap.amazon.com", "ModifyShoppingCartItemsRequest"]],
        [:retval, "ShoppingCart", ["ShoppingCart", "http://soap.amazon.com", "ShoppingCart"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
    ],
    ["GetTransactionDetailsRequest", "getTransactionDetailsRequest",
      [
        [:in, "GetTransactionDetailsRequest", ["GetTransactionDetailsRequest", "http://soap.amazon.com", "GetTransactionDetailsRequest"]],
        [:retval, "GetTransactionDetailsResponse", ["GetTransactionDetailsResponse", "http://soap.amazon.com", "GetTransactionDetailsResponse"]]
      ],
      "http://soap.amazon.com", "http://soap.amazon.com", :rpc
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

