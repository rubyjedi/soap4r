require 'xsd/qname'

class StockQuoteServicePortType

   def getQuote(ticker)
      return 100 + rand * 50.0
   end

end
