# http://soap.amazon.com
class ProductLineArray < Array; end

# http://soap.amazon.com
class ProductLine
  def Mode
    @mode
  end

  def Mode=( newMode )
    @mode = newMode
  end

  def ProductInfo
    @productInfo
  end

  def ProductInfo=( newProductInfo )
    @productInfo = newProductInfo
  end

  def initialize( mode = nil,
      productInfo = nil )
    @mode = mode
    @productInfo = productInfo
  end
end

# http://soap.amazon.com
class ProductInfo
  def TotalResults
    @totalResults
  end

  def TotalResults=( newTotalResults )
    @totalResults = newTotalResults
  end

  def TotalPages
    @totalPages
  end

  def TotalPages=( newTotalPages )
    @totalPages = newTotalPages
  end

  def ListName
    @listName
  end

  def ListName=( newListName )
    @listName = newListName
  end

  def Details
    @details
  end

  def Details=( newDetails )
    @details = newDetails
  end

  def initialize( totalResults = nil,
      totalPages = nil,
      listName = nil,
      details = nil )
    @totalResults = totalResults
    @totalPages = totalPages
    @listName = listName
    @details = details
  end
end

# http://soap.amazon.com
class DetailsArray < Array; end

# http://soap.amazon.com
class Details
  def Url
    @url
  end

  def Url=( newUrl )
    @url = newUrl
  end

  def Asin
    @asin
  end

  def Asin=( newAsin )
    @asin = newAsin
  end

  def ProductName
    @productName
  end

  def ProductName=( newProductName )
    @productName = newProductName
  end

  def Catalog
    @catalog
  end

  def Catalog=( newCatalog )
    @catalog = newCatalog
  end

  def KeyPhrases
    @keyPhrases
  end

  def KeyPhrases=( newKeyPhrases )
    @keyPhrases = newKeyPhrases
  end

  def Artists
    @artists
  end

  def Artists=( newArtists )
    @artists = newArtists
  end

  def Authors
    @authors
  end

  def Authors=( newAuthors )
    @authors = newAuthors
  end

  def Mpn
    @mpn
  end

  def Mpn=( newMpn )
    @mpn = newMpn
  end

  def Starring
    @starring
  end

  def Starring=( newStarring )
    @starring = newStarring
  end

  def Directors
    @directors
  end

  def Directors=( newDirectors )
    @directors = newDirectors
  end

  def TheatricalReleaseDate
    @theatricalReleaseDate
  end

  def TheatricalReleaseDate=( newTheatricalReleaseDate )
    @theatricalReleaseDate = newTheatricalReleaseDate
  end

  def ReleaseDate
    @releaseDate
  end

  def ReleaseDate=( newReleaseDate )
    @releaseDate = newReleaseDate
  end

  def Manufacturer
    @manufacturer
  end

  def Manufacturer=( newManufacturer )
    @manufacturer = newManufacturer
  end

  def Distributor
    @distributor
  end

  def Distributor=( newDistributor )
    @distributor = newDistributor
  end

  def ImageUrlSmall
    @imageUrlSmall
  end

  def ImageUrlSmall=( newImageUrlSmall )
    @imageUrlSmall = newImageUrlSmall
  end

  def ImageUrlMedium
    @imageUrlMedium
  end

  def ImageUrlMedium=( newImageUrlMedium )
    @imageUrlMedium = newImageUrlMedium
  end

  def ImageUrlLarge
    @imageUrlLarge
  end

  def ImageUrlLarge=( newImageUrlLarge )
    @imageUrlLarge = newImageUrlLarge
  end

  def ListPrice
    @listPrice
  end

  def ListPrice=( newListPrice )
    @listPrice = newListPrice
  end

  def OurPrice
    @ourPrice
  end

  def OurPrice=( newOurPrice )
    @ourPrice = newOurPrice
  end

  def UsedPrice
    @usedPrice
  end

  def UsedPrice=( newUsedPrice )
    @usedPrice = newUsedPrice
  end

  def RefurbishedPrice
    @refurbishedPrice
  end

  def RefurbishedPrice=( newRefurbishedPrice )
    @refurbishedPrice = newRefurbishedPrice
  end

  def CollectiblePrice
    @collectiblePrice
  end

  def CollectiblePrice=( newCollectiblePrice )
    @collectiblePrice = newCollectiblePrice
  end

  def ThirdPartyNewPrice
    @thirdPartyNewPrice
  end

  def ThirdPartyNewPrice=( newThirdPartyNewPrice )
    @thirdPartyNewPrice = newThirdPartyNewPrice
  end

  def NumberOfOfferings
    @numberOfOfferings
  end

  def NumberOfOfferings=( newNumberOfOfferings )
    @numberOfOfferings = newNumberOfOfferings
  end

  def ThirdPartyNewCount
    @thirdPartyNewCount
  end

  def ThirdPartyNewCount=( newThirdPartyNewCount )
    @thirdPartyNewCount = newThirdPartyNewCount
  end

  def UsedCount
    @usedCount
  end

  def UsedCount=( newUsedCount )
    @usedCount = newUsedCount
  end

  def CollectibleCount
    @collectibleCount
  end

  def CollectibleCount=( newCollectibleCount )
    @collectibleCount = newCollectibleCount
  end

  def RefurbishedCount
    @refurbishedCount
  end

  def RefurbishedCount=( newRefurbishedCount )
    @refurbishedCount = newRefurbishedCount
  end

  def ThirdPartyProductInfo
    @thirdPartyProductInfo
  end

  def ThirdPartyProductInfo=( newThirdPartyProductInfo )
    @thirdPartyProductInfo = newThirdPartyProductInfo
  end

  def SalesRank
    @salesRank
  end

  def SalesRank=( newSalesRank )
    @salesRank = newSalesRank
  end

  def BrowseList
    @browseList
  end

  def BrowseList=( newBrowseList )
    @browseList = newBrowseList
  end

  def Media
    @media
  end

  def Media=( newMedia )
    @media = newMedia
  end

  def ReadingLevel
    @readingLevel
  end

  def ReadingLevel=( newReadingLevel )
    @readingLevel = newReadingLevel
  end

  def Publisher
    @publisher
  end

  def Publisher=( newPublisher )
    @publisher = newPublisher
  end

  def NumMedia
    @numMedia
  end

  def NumMedia=( newNumMedia )
    @numMedia = newNumMedia
  end

  def Isbn
    @isbn
  end

  def Isbn=( newIsbn )
    @isbn = newIsbn
  end

  def Features
    @features
  end

  def Features=( newFeatures )
    @features = newFeatures
  end

  def MpaaRating
    @mpaaRating
  end

  def MpaaRating=( newMpaaRating )
    @mpaaRating = newMpaaRating
  end

  def EsrbRating
    @esrbRating
  end

  def EsrbRating=( newEsrbRating )
    @esrbRating = newEsrbRating
  end

  def AgeGroup
    @ageGroup
  end

  def AgeGroup=( newAgeGroup )
    @ageGroup = newAgeGroup
  end

  def Availability
    @availability
  end

  def Availability=( newAvailability )
    @availability = newAvailability
  end

  def Upc
    @upc
  end

  def Upc=( newUpc )
    @upc = newUpc
  end

  def Tracks
    @tracks
  end

  def Tracks=( newTracks )
    @tracks = newTracks
  end

  def Accessories
    @accessories
  end

  def Accessories=( newAccessories )
    @accessories = newAccessories
  end

  def Platforms
    @platforms
  end

  def Platforms=( newPlatforms )
    @platforms = newPlatforms
  end

  def Encoding
    @encoding
  end

  def Encoding=( newEncoding )
    @encoding = newEncoding
  end

  def Reviews
    @reviews
  end

  def Reviews=( newReviews )
    @reviews = newReviews
  end

  def SimilarProducts
    @similarProducts
  end

  def SimilarProducts=( newSimilarProducts )
    @similarProducts = newSimilarProducts
  end

  def Lists
    @lists
  end

  def Lists=( newLists )
    @lists = newLists
  end

  def Status
    @status
  end

  def Status=( newStatus )
    @status = newStatus
  end

  def initialize( url = nil,
      asin = nil,
      productName = nil,
      catalog = nil,
      keyPhrases = nil,
      artists = nil,
      authors = nil,
      mpn = nil,
      starring = nil,
      directors = nil,
      theatricalReleaseDate = nil,
      releaseDate = nil,
      manufacturer = nil,
      distributor = nil,
      imageUrlSmall = nil,
      imageUrlMedium = nil,
      imageUrlLarge = nil,
      listPrice = nil,
      ourPrice = nil,
      usedPrice = nil,
      refurbishedPrice = nil,
      collectiblePrice = nil,
      thirdPartyNewPrice = nil,
      numberOfOfferings = nil,
      thirdPartyNewCount = nil,
      usedCount = nil,
      collectibleCount = nil,
      refurbishedCount = nil,
      thirdPartyProductInfo = nil,
      salesRank = nil,
      browseList = nil,
      media = nil,
      readingLevel = nil,
      publisher = nil,
      numMedia = nil,
      isbn = nil,
      features = nil,
      mpaaRating = nil,
      esrbRating = nil,
      ageGroup = nil,
      availability = nil,
      upc = nil,
      tracks = nil,
      accessories = nil,
      platforms = nil,
      encoding = nil,
      reviews = nil,
      similarProducts = nil,
      lists = nil,
      status = nil )
    @url = url
    @asin = asin
    @productName = productName
    @catalog = catalog
    @keyPhrases = keyPhrases
    @artists = artists
    @authors = authors
    @mpn = mpn
    @starring = starring
    @directors = directors
    @theatricalReleaseDate = theatricalReleaseDate
    @releaseDate = releaseDate
    @manufacturer = manufacturer
    @distributor = distributor
    @imageUrlSmall = imageUrlSmall
    @imageUrlMedium = imageUrlMedium
    @imageUrlLarge = imageUrlLarge
    @listPrice = listPrice
    @ourPrice = ourPrice
    @usedPrice = usedPrice
    @refurbishedPrice = refurbishedPrice
    @collectiblePrice = collectiblePrice
    @thirdPartyNewPrice = thirdPartyNewPrice
    @numberOfOfferings = numberOfOfferings
    @thirdPartyNewCount = thirdPartyNewCount
    @usedCount = usedCount
    @collectibleCount = collectibleCount
    @refurbishedCount = refurbishedCount
    @thirdPartyProductInfo = thirdPartyProductInfo
    @salesRank = salesRank
    @browseList = browseList
    @media = media
    @readingLevel = readingLevel
    @publisher = publisher
    @numMedia = numMedia
    @isbn = isbn
    @features = features
    @mpaaRating = mpaaRating
    @esrbRating = esrbRating
    @ageGroup = ageGroup
    @availability = availability
    @upc = upc
    @tracks = tracks
    @accessories = accessories
    @platforms = platforms
    @encoding = encoding
    @reviews = reviews
    @similarProducts = similarProducts
    @lists = lists
    @status = status
  end
end

# http://soap.amazon.com
class KeyPhraseArray < Array; end

# http://soap.amazon.com
class KeyPhrase
  def KeyPhrase
    @keyPhrase
  end

  def KeyPhrase=( newKeyPhrase )
    @keyPhrase = newKeyPhrase
  end

  def Type
    @type
  end

  def Type=( newType )
    @type = newType
  end

  def initialize( keyPhrase = nil,
      type = nil )
    @keyPhrase = keyPhrase
    @type = type
  end
end

# http://soap.amazon.com
class ArtistArray < Array; end

# http://soap.amazon.com
class AuthorArray < Array; end

# http://soap.amazon.com
class StarringArray < Array; end

# http://soap.amazon.com
class DirectorArray < Array; end

# http://soap.amazon.com
class BrowseNodeArray < Array; end

# http://soap.amazon.com
class BrowseNode
  def BrowseId
    @browseId
  end

  def BrowseId=( newBrowseId )
    @browseId = newBrowseId
  end

  def BrowseName
    @browseName
  end

  def BrowseName=( newBrowseName )
    @browseName = newBrowseName
  end

  def initialize( browseId = nil,
      browseName = nil )
    @browseId = browseId
    @browseName = browseName
  end
end

# http://soap.amazon.com
class FeaturesArray < Array; end

# http://soap.amazon.com
class TrackArray < Array; end

# http://soap.amazon.com
class Track
  def TrackName
    @trackName
  end

  def TrackName=( newTrackName )
    @trackName = newTrackName
  end

  def ByArtist
    @byArtist
  end

  def ByArtist=( newByArtist )
    @byArtist = newByArtist
  end

  def initialize( trackName = nil,
      byArtist = nil )
    @trackName = trackName
    @byArtist = byArtist
  end
end

# http://soap.amazon.com
class AccessoryArray < Array; end

# http://soap.amazon.com
class PlatformArray < Array; end

# http://soap.amazon.com
class Reviews
  def AvgCustomerRating
    @avgCustomerRating
  end

  def AvgCustomerRating=( newAvgCustomerRating )
    @avgCustomerRating = newAvgCustomerRating
  end

  def TotalCustomerReviews
    @totalCustomerReviews
  end

  def TotalCustomerReviews=( newTotalCustomerReviews )
    @totalCustomerReviews = newTotalCustomerReviews
  end

  def CustomerReviews
    @customerReviews
  end

  def CustomerReviews=( newCustomerReviews )
    @customerReviews = newCustomerReviews
  end

  def initialize( avgCustomerRating = nil,
      totalCustomerReviews = nil,
      customerReviews = nil )
    @avgCustomerRating = avgCustomerRating
    @totalCustomerReviews = totalCustomerReviews
    @customerReviews = customerReviews
  end
end

# http://soap.amazon.com
class CustomerReviewArray < Array; end

# http://soap.amazon.com
class CustomerReview
  def Rating
    @rating
  end

  def Rating=( newRating )
    @rating = newRating
  end

  def Summary
    @summary
  end

  def Summary=( newSummary )
    @summary = newSummary
  end

  def Comment
    @comment
  end

  def Comment=( newComment )
    @comment = newComment
  end

  def initialize( rating = nil,
      summary = nil,
      comment = nil )
    @rating = rating
    @summary = summary
    @comment = comment
  end
end

# http://soap.amazon.com
class SimilarProductsArray < Array; end

# http://soap.amazon.com
class ListArray < Array; end

# http://soap.amazon.com
class MarketplaceSearch
  def MarketplaceSearchDetails
    @marketplaceSearchDetails
  end

  def MarketplaceSearchDetails=( newMarketplaceSearchDetails )
    @marketplaceSearchDetails = newMarketplaceSearchDetails
  end

  def initialize( marketplaceSearchDetails = nil )
    @marketplaceSearchDetails = marketplaceSearchDetails
  end
end

# http://soap.amazon.com
class SellerProfile
  def SellerProfileDetails
    @sellerProfileDetails
  end

  def SellerProfileDetails=( newSellerProfileDetails )
    @sellerProfileDetails = newSellerProfileDetails
  end

  def initialize( sellerProfileDetails = nil )
    @sellerProfileDetails = sellerProfileDetails
  end
end

# http://soap.amazon.com
class SellerSearch
  def SellerSearchDetails
    @sellerSearchDetails
  end

  def SellerSearchDetails=( newSellerSearchDetails )
    @sellerSearchDetails = newSellerSearchDetails
  end

  def initialize( sellerSearchDetails = nil )
    @sellerSearchDetails = sellerSearchDetails
  end
end

# http://soap.amazon.com
class MarketplaceSearchDetails
  def NumberOfOpenListings
    @numberOfOpenListings
  end

  def NumberOfOpenListings=( newNumberOfOpenListings )
    @numberOfOpenListings = newNumberOfOpenListings
  end

  def ListingProductInfo
    @listingProductInfo
  end

  def ListingProductInfo=( newListingProductInfo )
    @listingProductInfo = newListingProductInfo
  end

  def initialize( numberOfOpenListings = nil,
      listingProductInfo = nil )
    @numberOfOpenListings = numberOfOpenListings
    @listingProductInfo = listingProductInfo
  end
end

# http://soap.amazon.com
class MarketplaceSearchDetailsArray < Array; end

# http://soap.amazon.com
class SellerProfileDetails
  def SellerNickname
    @sellerNickname
  end

  def SellerNickname=( newSellerNickname )
    @sellerNickname = newSellerNickname
  end

  def OverallFeedbackRating
    @overallFeedbackRating
  end

  def OverallFeedbackRating=( newOverallFeedbackRating )
    @overallFeedbackRating = newOverallFeedbackRating
  end

  def NumberOfFeedback
    @numberOfFeedback
  end

  def NumberOfFeedback=( newNumberOfFeedback )
    @numberOfFeedback = newNumberOfFeedback
  end

  def NumberOfCanceledBids
    @numberOfCanceledBids
  end

  def NumberOfCanceledBids=( newNumberOfCanceledBids )
    @numberOfCanceledBids = newNumberOfCanceledBids
  end

  def NumberOfCanceledAuctions
    @numberOfCanceledAuctions
  end

  def NumberOfCanceledAuctions=( newNumberOfCanceledAuctions )
    @numberOfCanceledAuctions = newNumberOfCanceledAuctions
  end

  def StoreId
    @storeId
  end

  def StoreId=( newStoreId )
    @storeId = newStoreId
  end

  def StoreName
    @storeName
  end

  def StoreName=( newStoreName )
    @storeName = newStoreName
  end

  def SellerFeedback
    @sellerFeedback
  end

  def SellerFeedback=( newSellerFeedback )
    @sellerFeedback = newSellerFeedback
  end

  def initialize( sellerNickname = nil,
      overallFeedbackRating = nil,
      numberOfFeedback = nil,
      numberOfCanceledBids = nil,
      numberOfCanceledAuctions = nil,
      storeId = nil,
      storeName = nil,
      sellerFeedback = nil )
    @sellerNickname = sellerNickname
    @overallFeedbackRating = overallFeedbackRating
    @numberOfFeedback = numberOfFeedback
    @numberOfCanceledBids = numberOfCanceledBids
    @numberOfCanceledAuctions = numberOfCanceledAuctions
    @storeId = storeId
    @storeName = storeName
    @sellerFeedback = sellerFeedback
  end
end

# http://soap.amazon.com
class SellerProfileDetailsArray < Array; end

# http://soap.amazon.com
class SellerSearchDetails
  def SellerNickname
    @sellerNickname
  end

  def SellerNickname=( newSellerNickname )
    @sellerNickname = newSellerNickname
  end

  def StoreId
    @storeId
  end

  def StoreId=( newStoreId )
    @storeId = newStoreId
  end

  def StoreName
    @storeName
  end

  def StoreName=( newStoreName )
    @storeName = newStoreName
  end

  def NumberOfOpenListings
    @numberOfOpenListings
  end

  def NumberOfOpenListings=( newNumberOfOpenListings )
    @numberOfOpenListings = newNumberOfOpenListings
  end

  def ListingProductInfo
    @listingProductInfo
  end

  def ListingProductInfo=( newListingProductInfo )
    @listingProductInfo = newListingProductInfo
  end

  def initialize( sellerNickname = nil,
      storeId = nil,
      storeName = nil,
      numberOfOpenListings = nil,
      listingProductInfo = nil )
    @sellerNickname = sellerNickname
    @storeId = storeId
    @storeName = storeName
    @numberOfOpenListings = numberOfOpenListings
    @listingProductInfo = listingProductInfo
  end
end

# http://soap.amazon.com
class SellerSearchDetailsArray < Array; end

# http://soap.amazon.com
class ListingProductInfo
  def ListingProductDetails
    @listingProductDetails
  end

  def ListingProductDetails=( newListingProductDetails )
    @listingProductDetails = newListingProductDetails
  end

  def initialize( listingProductDetails = nil )
    @listingProductDetails = listingProductDetails
  end
end

# http://soap.amazon.com
class ListingProductDetailsArray < Array; end

# http://soap.amazon.com
class ListingProductDetails
  def ExchangeId
    @exchangeId
  end

  def ExchangeId=( newExchangeId )
    @exchangeId = newExchangeId
  end

  def ListingId
    @listingId
  end

  def ListingId=( newListingId )
    @listingId = newListingId
  end

  def ExchangeTitle
    @exchangeTitle
  end

  def ExchangeTitle=( newExchangeTitle )
    @exchangeTitle = newExchangeTitle
  end

  def ExchangePrice
    @exchangePrice
  end

  def ExchangePrice=( newExchangePrice )
    @exchangePrice = newExchangePrice
  end

  def ExchangeAsin
    @exchangeAsin
  end

  def ExchangeAsin=( newExchangeAsin )
    @exchangeAsin = newExchangeAsin
  end

  def ExchangeEndDate
    @exchangeEndDate
  end

  def ExchangeEndDate=( newExchangeEndDate )
    @exchangeEndDate = newExchangeEndDate
  end

  def ExchangeTinyImage
    @exchangeTinyImage
  end

  def ExchangeTinyImage=( newExchangeTinyImage )
    @exchangeTinyImage = newExchangeTinyImage
  end

  def ExchangeSellerId
    @exchangeSellerId
  end

  def ExchangeSellerId=( newExchangeSellerId )
    @exchangeSellerId = newExchangeSellerId
  end

  def ExchangeSellerNickname
    @exchangeSellerNickname
  end

  def ExchangeSellerNickname=( newExchangeSellerNickname )
    @exchangeSellerNickname = newExchangeSellerNickname
  end

  def ExchangeStartDate
    @exchangeStartDate
  end

  def ExchangeStartDate=( newExchangeStartDate )
    @exchangeStartDate = newExchangeStartDate
  end

  def ExchangeStatus
    @exchangeStatus
  end

  def ExchangeStatus=( newExchangeStatus )
    @exchangeStatus = newExchangeStatus
  end

  def ExchangeQuantity
    @exchangeQuantity
  end

  def ExchangeQuantity=( newExchangeQuantity )
    @exchangeQuantity = newExchangeQuantity
  end

  def ExchangeQuantityAllocated
    @exchangeQuantityAllocated
  end

  def ExchangeQuantityAllocated=( newExchangeQuantityAllocated )
    @exchangeQuantityAllocated = newExchangeQuantityAllocated
  end

  def ExchangeFeaturedCategory
    @exchangeFeaturedCategory
  end

  def ExchangeFeaturedCategory=( newExchangeFeaturedCategory )
    @exchangeFeaturedCategory = newExchangeFeaturedCategory
  end

  def ExchangeCondition
    @exchangeCondition
  end

  def ExchangeCondition=( newExchangeCondition )
    @exchangeCondition = newExchangeCondition
  end

  def ExchangeConditionType
    @exchangeConditionType
  end

  def ExchangeConditionType=( newExchangeConditionType )
    @exchangeConditionType = newExchangeConditionType
  end

  def ExchangeAvailability
    @exchangeAvailability
  end

  def ExchangeAvailability=( newExchangeAvailability )
    @exchangeAvailability = newExchangeAvailability
  end

  def ExchangeOfferingType
    @exchangeOfferingType
  end

  def ExchangeOfferingType=( newExchangeOfferingType )
    @exchangeOfferingType = newExchangeOfferingType
  end

  def ExchangeSellerState
    @exchangeSellerState
  end

  def ExchangeSellerState=( newExchangeSellerState )
    @exchangeSellerState = newExchangeSellerState
  end

  def ExchangeSellerCountry
    @exchangeSellerCountry
  end

  def ExchangeSellerCountry=( newExchangeSellerCountry )
    @exchangeSellerCountry = newExchangeSellerCountry
  end

  def ExchangeSellerRating
    @exchangeSellerRating
  end

  def ExchangeSellerRating=( newExchangeSellerRating )
    @exchangeSellerRating = newExchangeSellerRating
  end

  def initialize( exchangeId = nil,
      listingId = nil,
      exchangeTitle = nil,
      exchangePrice = nil,
      exchangeAsin = nil,
      exchangeEndDate = nil,
      exchangeTinyImage = nil,
      exchangeSellerId = nil,
      exchangeSellerNickname = nil,
      exchangeStartDate = nil,
      exchangeStatus = nil,
      exchangeQuantity = nil,
      exchangeQuantityAllocated = nil,
      exchangeFeaturedCategory = nil,
      exchangeCondition = nil,
      exchangeConditionType = nil,
      exchangeAvailability = nil,
      exchangeOfferingType = nil,
      exchangeSellerState = nil,
      exchangeSellerCountry = nil,
      exchangeSellerRating = nil )
    @exchangeId = exchangeId
    @listingId = listingId
    @exchangeTitle = exchangeTitle
    @exchangePrice = exchangePrice
    @exchangeAsin = exchangeAsin
    @exchangeEndDate = exchangeEndDate
    @exchangeTinyImage = exchangeTinyImage
    @exchangeSellerId = exchangeSellerId
    @exchangeSellerNickname = exchangeSellerNickname
    @exchangeStartDate = exchangeStartDate
    @exchangeStatus = exchangeStatus
    @exchangeQuantity = exchangeQuantity
    @exchangeQuantityAllocated = exchangeQuantityAllocated
    @exchangeFeaturedCategory = exchangeFeaturedCategory
    @exchangeCondition = exchangeCondition
    @exchangeConditionType = exchangeConditionType
    @exchangeAvailability = exchangeAvailability
    @exchangeOfferingType = exchangeOfferingType
    @exchangeSellerState = exchangeSellerState
    @exchangeSellerCountry = exchangeSellerCountry
    @exchangeSellerRating = exchangeSellerRating
  end
end

# http://soap.amazon.com
class SellerFeedback
  def Feedback
    @feedback
  end

  def Feedback=( newFeedback )
    @feedback = newFeedback
  end

  def initialize( feedback = nil )
    @feedback = feedback
  end
end

# http://soap.amazon.com
class FeedbackArray < Array; end

# http://soap.amazon.com
class Feedback
  def FeedbackRating
    @feedbackRating
  end

  def FeedbackRating=( newFeedbackRating )
    @feedbackRating = newFeedbackRating
  end

  def FeedbackComments
    @feedbackComments
  end

  def FeedbackComments=( newFeedbackComments )
    @feedbackComments = newFeedbackComments
  end

  def FeedbackDate
    @feedbackDate
  end

  def FeedbackDate=( newFeedbackDate )
    @feedbackDate = newFeedbackDate
  end

  def FeedbackRater
    @feedbackRater
  end

  def FeedbackRater=( newFeedbackRater )
    @feedbackRater = newFeedbackRater
  end

  def initialize( feedbackRating = nil,
      feedbackComments = nil,
      feedbackDate = nil,
      feedbackRater = nil )
    @feedbackRating = feedbackRating
    @feedbackComments = feedbackComments
    @feedbackDate = feedbackDate
    @feedbackRater = feedbackRater
  end
end

# http://soap.amazon.com
class ThirdPartyProductInfo
  def ThirdPartyProductDetails
    @thirdPartyProductDetails
  end

  def ThirdPartyProductDetails=( newThirdPartyProductDetails )
    @thirdPartyProductDetails = newThirdPartyProductDetails
  end

  def initialize( thirdPartyProductDetails = nil )
    @thirdPartyProductDetails = thirdPartyProductDetails
  end
end

# http://soap.amazon.com
class ThirdPartyProductDetailsArray < Array; end

# http://soap.amazon.com
class ThirdPartyProductDetails
  def OfferingType
    @offeringType
  end

  def OfferingType=( newOfferingType )
    @offeringType = newOfferingType
  end

  def SellerId
    @sellerId
  end

  def SellerId=( newSellerId )
    @sellerId = newSellerId
  end

  def SellerNickname
    @sellerNickname
  end

  def SellerNickname=( newSellerNickname )
    @sellerNickname = newSellerNickname
  end

  def ExchangeId
    @exchangeId
  end

  def ExchangeId=( newExchangeId )
    @exchangeId = newExchangeId
  end

  def OfferingPrice
    @offeringPrice
  end

  def OfferingPrice=( newOfferingPrice )
    @offeringPrice = newOfferingPrice
  end

  def Condition
    @condition
  end

  def Condition=( newCondition )
    @condition = newCondition
  end

  def ConditionType
    @conditionType
  end

  def ConditionType=( newConditionType )
    @conditionType = newConditionType
  end

  def ExchangeAvailability
    @exchangeAvailability
  end

  def ExchangeAvailability=( newExchangeAvailability )
    @exchangeAvailability = newExchangeAvailability
  end

  def SellerCountry
    @sellerCountry
  end

  def SellerCountry=( newSellerCountry )
    @sellerCountry = newSellerCountry
  end

  def SellerState
    @sellerState
  end

  def SellerState=( newSellerState )
    @sellerState = newSellerState
  end

  def ShipComments
    @shipComments
  end

  def ShipComments=( newShipComments )
    @shipComments = newShipComments
  end

  def SellerRating
    @sellerRating
  end

  def SellerRating=( newSellerRating )
    @sellerRating = newSellerRating
  end

  def initialize( offeringType = nil,
      sellerId = nil,
      sellerNickname = nil,
      exchangeId = nil,
      offeringPrice = nil,
      condition = nil,
      conditionType = nil,
      exchangeAvailability = nil,
      sellerCountry = nil,
      sellerState = nil,
      shipComments = nil,
      sellerRating = nil )
    @offeringType = offeringType
    @sellerId = sellerId
    @sellerNickname = sellerNickname
    @exchangeId = exchangeId
    @offeringPrice = offeringPrice
    @condition = condition
    @conditionType = conditionType
    @exchangeAvailability = exchangeAvailability
    @sellerCountry = sellerCountry
    @sellerState = sellerState
    @shipComments = shipComments
    @sellerRating = sellerRating
  end
end

# http://soap.amazon.com
class KeywordRequest
  def keyword
    @keyword
  end

  def keyword=( newkeyword )
    @keyword = newkeyword
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( keyword = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @keyword = keyword
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class PowerRequest
  def power
    @power
  end

  def power=( newpower )
    @power = newpower
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( power = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @power = power
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class BrowseNodeRequest
  def browse_node
    @browse_node
  end

  def browse_node=( newbrowse_node )
    @browse_node = newbrowse_node
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( browse_node = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @browse_node = browse_node
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class AsinRequest
  def asin
    @asin
  end

  def asin=( newasin )
    @asin = newasin
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def offer
    @offer
  end

  def offer=( newoffer )
    @offer = newoffer
  end

  def offerpage
    @offerpage
  end

  def offerpage=( newofferpage )
    @offerpage = newofferpage
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( asin = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      offer = nil,
      offerpage = nil,
      locale = nil )
    @asin = asin
    @tag = tag
    @type = type
    @devtag = devtag
    @offer = offer
    @offerpage = offerpage
    @locale = locale
  end
end

# http://soap.amazon.com
class BlendedRequest
  def blended
    @blended
  end

  def blended=( newblended )
    @blended = newblended
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( blended = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      locale = nil )
    @blended = blended
    @tag = tag
    @type = type
    @devtag = devtag
    @locale = locale
  end
end

# http://soap.amazon.com
class UpcRequest
  def upc
    @upc
  end

  def upc=( newupc )
    @upc = newupc
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( upc = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @upc = upc
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class ArtistRequest
  def artist
    @artist
  end

  def artist=( newartist )
    @artist = newartist
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( artist = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @artist = artist
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class AuthorRequest
  def author
    @author
  end

  def author=( newauthor )
    @author = newauthor
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( author = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @author = author
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class ActorRequest
  def actor
    @actor
  end

  def actor=( newactor )
    @actor = newactor
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( actor = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @actor = actor
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class DirectorRequest
  def director
    @director
  end

  def director=( newdirector )
    @director = newdirector
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( director = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @director = director
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class ExchangeRequest
  def exchange_id
    @exchange_id
  end

  def exchange_id=( newexchange_id )
    @exchange_id = newexchange_id
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( exchange_id = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      locale = nil )
    @exchange_id = exchange_id
    @tag = tag
    @type = type
    @devtag = devtag
    @locale = locale
  end
end

# http://soap.amazon.com
class ManufacturerRequest
  def manufacturer
    @manufacturer
  end

  def manufacturer=( newmanufacturer )
    @manufacturer = newmanufacturer
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def mode
    @mode
  end

  def mode=( newmode )
    @mode = newmode
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def sort
    @sort
  end

  def sort=( newsort )
    @sort = newsort
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( manufacturer = nil,
      page = nil,
      mode = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      sort = nil,
      locale = nil )
    @manufacturer = manufacturer
    @page = page
    @mode = mode
    @tag = tag
    @type = type
    @devtag = devtag
    @sort = sort
    @locale = locale
  end
end

# http://soap.amazon.com
class ListManiaRequest
  def lm_id
    @lm_id
  end

  def lm_id=( newlm_id )
    @lm_id = newlm_id
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( lm_id = nil,
      page = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      locale = nil )
    @lm_id = lm_id
    @page = page
    @tag = tag
    @type = type
    @devtag = devtag
    @locale = locale
  end
end

# http://soap.amazon.com
class WishlistRequest
  def wishlist_id
    @wishlist_id
  end

  def wishlist_id=( newwishlist_id )
    @wishlist_id = newwishlist_id
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( wishlist_id = nil,
      page = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      locale = nil )
    @wishlist_id = wishlist_id
    @page = page
    @tag = tag
    @type = type
    @devtag = devtag
    @locale = locale
  end
end

# http://soap.amazon.com
class MarketplaceRequest
  def marketplace_search
    @marketplace_search
  end

  def marketplace_search=( newmarketplace_search )
    @marketplace_search = newmarketplace_search
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def keyword
    @keyword
  end

  def keyword=( newkeyword )
    @keyword = newkeyword
  end

  def keyword_search
    @keyword_search
  end

  def keyword_search=( newkeyword_search )
    @keyword_search = newkeyword_search
  end

  def browse_id
    @browse_id
  end

  def browse_id=( newbrowse_id )
    @browse_id = newbrowse_id
  end

  def zipcode
    @zipcode
  end

  def zipcode=( newzipcode )
    @zipcode = newzipcode
  end

  def area_id
    @area_id
  end

  def area_id=( newarea_id )
    @area_id = newarea_id
  end

  def geo
    @geo
  end

  def geo=( newgeo )
    @geo = newgeo
  end

  def rank
    @rank
  end

  def rank=( newrank )
    @rank = newrank
  end

  def listing_id
    @listing_id
  end

  def listing_id=( newlisting_id )
    @listing_id = newlisting_id
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def index
    @index
  end

  def index=( newindex )
    @index = newindex
  end

  def initialize( marketplace_search = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      page = nil,
      keyword = nil,
      keyword_search = nil,
      browse_id = nil,
      zipcode = nil,
      area_id = nil,
      geo = nil,
      rank = nil,
      listing_id = nil,
      locale = nil,
      index = nil )
    @marketplace_search = marketplace_search
    @tag = tag
    @type = type
    @devtag = devtag
    @page = page
    @keyword = keyword
    @keyword_search = keyword_search
    @browse_id = browse_id
    @zipcode = zipcode
    @area_id = area_id
    @geo = geo
    @rank = rank
    @listing_id = listing_id
    @locale = locale
    @index = index
  end
end

# http://soap.amazon.com
class SellerProfileRequest
  def seller_id
    @seller_id
  end

  def seller_id=( newseller_id )
    @seller_id = newseller_id
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( seller_id = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      page = nil,
      locale = nil )
    @seller_id = seller_id
    @tag = tag
    @type = type
    @devtag = devtag
    @page = page
    @locale = locale
  end
end

# http://soap.amazon.com
class SellerRequest
  def seller_id
    @seller_id
  end

  def seller_id=( newseller_id )
    @seller_id = newseller_id
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def offerstatus
    @offerstatus
  end

  def offerstatus=( newofferstatus )
    @offerstatus = newofferstatus
  end

  def page
    @page
  end

  def page=( newpage )
    @page = newpage
  end

  def seller_browse_id
    @seller_browse_id
  end

  def seller_browse_id=( newseller_browse_id )
    @seller_browse_id = newseller_browse_id
  end

  def keyword
    @keyword
  end

  def keyword=( newkeyword )
    @keyword = newkeyword
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def index
    @index
  end

  def index=( newindex )
    @index = newindex
  end

  def initialize( seller_id = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      offerstatus = nil,
      page = nil,
      seller_browse_id = nil,
      keyword = nil,
      locale = nil,
      index = nil )
    @seller_id = seller_id
    @tag = tag
    @type = type
    @devtag = devtag
    @offerstatus = offerstatus
    @page = page
    @seller_browse_id = seller_browse_id
    @keyword = keyword
    @locale = locale
    @index = index
  end
end

# http://soap.amazon.com
class SimilarityRequest
  def asin
    @asin
  end

  def asin=( newasin )
    @asin = newasin
  end

  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def type
    @type
  end

  def type=( newtype )
    @type = newtype
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( asin = nil,
      tag = nil,
      type = nil,
      devtag = nil,
      locale = nil )
    @asin = asin
    @tag = tag
    @type = type
    @devtag = devtag
    @locale = locale
  end
end

# http://soap.amazon.com
class ItemIdArray < Array; end

# http://soap.amazon.com
class ItemArray < Array; end

# http://soap.amazon.com
class Item
  def ItemId
    @itemId
  end

  def ItemId=( newItemId )
    @itemId = newItemId
  end

  def ProductName
    @productName
  end

  def ProductName=( newProductName )
    @productName = newProductName
  end

  def Catalog
    @catalog
  end

  def Catalog=( newCatalog )
    @catalog = newCatalog
  end

  def Asin
    @asin
  end

  def Asin=( newAsin )
    @asin = newAsin
  end

  def ExchangeId
    @exchangeId
  end

  def ExchangeId=( newExchangeId )
    @exchangeId = newExchangeId
  end

  def Quantity
    @quantity
  end

  def Quantity=( newQuantity )
    @quantity = newQuantity
  end

  def ListPrice
    @listPrice
  end

  def ListPrice=( newListPrice )
    @listPrice = newListPrice
  end

  def OurPrice
    @ourPrice
  end

  def OurPrice=( newOurPrice )
    @ourPrice = newOurPrice
  end

  def initialize( itemId = nil,
      productName = nil,
      catalog = nil,
      asin = nil,
      exchangeId = nil,
      quantity = nil,
      listPrice = nil,
      ourPrice = nil )
    @itemId = itemId
    @productName = productName
    @catalog = catalog
    @asin = asin
    @exchangeId = exchangeId
    @quantity = quantity
    @listPrice = listPrice
    @ourPrice = ourPrice
  end
end

# http://soap.amazon.com
class ItemQuantityArray < Array; end

# http://soap.amazon.com
class ItemQuantity
  def ItemId
    @itemId
  end

  def ItemId=( newItemId )
    @itemId = newItemId
  end

  def Quantity
    @quantity
  end

  def Quantity=( newQuantity )
    @quantity = newQuantity
  end

  def initialize( itemId = nil,
      quantity = nil )
    @itemId = itemId
    @quantity = quantity
  end
end

# http://soap.amazon.com
class AddItemArray < Array; end

# http://soap.amazon.com
class AddItem
  def Asin
    @asin
  end

  def Asin=( newAsin )
    @asin = newAsin
  end

  def ExchangeId
    @exchangeId
  end

  def ExchangeId=( newExchangeId )
    @exchangeId = newExchangeId
  end

  def Quantity
    @quantity
  end

  def Quantity=( newQuantity )
    @quantity = newQuantity
  end

  def initialize( asin = nil,
      exchangeId = nil,
      quantity = nil )
    @asin = asin
    @exchangeId = exchangeId
    @quantity = quantity
  end
end

# http://soap.amazon.com
class ShoppingCart
  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def PurchaseUrl
    @purchaseUrl
  end

  def PurchaseUrl=( newPurchaseUrl )
    @purchaseUrl = newPurchaseUrl
  end

  def Items
    @items
  end

  def Items=( newItems )
    @items = newItems
  end

  def initialize( cartId = nil,
      hMAC = nil,
      purchaseUrl = nil,
      items = nil )
    @cartId = cartId
    @hMAC = hMAC
    @purchaseUrl = purchaseUrl
    @items = items
  end
end

# http://soap.amazon.com
class GetShoppingCartRequest
  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( tag = nil,
      devtag = nil,
      cartId = nil,
      hMAC = nil,
      locale = nil )
    @tag = tag
    @devtag = devtag
    @cartId = cartId
    @hMAC = hMAC
    @locale = locale
  end
end

# http://soap.amazon.com
class ClearShoppingCartRequest
  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( tag = nil,
      devtag = nil,
      cartId = nil,
      hMAC = nil,
      locale = nil )
    @tag = tag
    @devtag = devtag
    @cartId = cartId
    @hMAC = hMAC
    @locale = locale
  end
end

# http://soap.amazon.com
class AddShoppingCartItemsRequest
  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def Items
    @items
  end

  def Items=( newItems )
    @items = newItems
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( tag = nil,
      devtag = nil,
      cartId = nil,
      hMAC = nil,
      items = nil,
      locale = nil )
    @tag = tag
    @devtag = devtag
    @cartId = cartId
    @hMAC = hMAC
    @items = items
    @locale = locale
  end
end

# http://soap.amazon.com
class RemoveShoppingCartItemsRequest
  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def Items
    @items
  end

  def Items=( newItems )
    @items = newItems
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( tag = nil,
      devtag = nil,
      cartId = nil,
      hMAC = nil,
      items = nil,
      locale = nil )
    @tag = tag
    @devtag = devtag
    @cartId = cartId
    @hMAC = hMAC
    @items = items
    @locale = locale
  end
end

# http://soap.amazon.com
class ModifyShoppingCartItemsRequest
  def tag
    @tag
  end

  def tag=( newtag )
    @tag = newtag
  end

  def devtag
    @devtag
  end

  def devtag=( newdevtag )
    @devtag = newdevtag
  end

  def CartId
    @cartId
  end

  def CartId=( newCartId )
    @cartId = newCartId
  end

  def HMAC
    @hMAC
  end

  def HMAC=( newHMAC )
    @hMAC = newHMAC
  end

  def Items
    @items
  end

  def Items=( newItems )
    @items = newItems
  end

  def locale
    @locale
  end

  def locale=( newlocale )
    @locale = newlocale
  end

  def initialize( tag = nil,
      devtag = nil,
      cartId = nil,
      hMAC = nil,
      items = nil,
      locale = nil )
    @tag = tag
    @devtag = devtag
    @cartId = cartId
    @hMAC = hMAC
    @items = items
    @locale = locale
  end
end

