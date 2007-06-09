Public Function testStockQuoteService(ticker As String) As Variant
    On Error GoTo ErrorHandler
    
    Dim soapClient
    Set soapClient = CreateObject("MSSoap.SoapClient")

    soapClient.mssoapinit("http://localhost/cgi-bin/stockQuoteService.cgi?wsdl")
        
    r = soapClient.getQuote(ticker)
    testStockQuoteService = r
    
Exit Function

ErrorHandler:
MsgBox Err.Description + vbCrLf + soapClient.faultactor + vbCrLf +
soapClient.faultcode + vbCrLf + soapClient.faultstring + vbCrLf +
soapClient.detail

End Function
