/*
# RAA SOAP interface client sample JScript version for Win32 box
# Original by fumiakiy [fumiakiy@ant.co.jp]
# 
# You need to download and install pocketSOAP/0.91 or later
# from http://www.pocketsoap.com/
*/

var uri = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1";
var endPoint = "http://raa.ruby-lang.org/soap/1.0/";
var proxySvr = "myProxyServer";
var proxyPort = 8080;

var e = WScript.CreateObject("PocketSOAP.Envelope");

var methodName = "getAllListings";
e.methodName = methodName;
e.URI = uri + "#" + methodName;
var x = e.serialize();

var t = WScript.CreateObject("PocketSOAP.HTTPTransport");
t.SetProxy(proxySvr, proxyPort);
t.Send(endPoint, x);
var r = t.Receive();

e.Parse(r);

var ret = "";
var arrRes = new VBArray(e.Parameters.ItemByName("return").Value);
for (var idx = arrRes.lbound(1); idx < arrRes.ubound(1); idx++) {
  ret += idx + " = " + arrRes.getItem(idx) + String.fromCharCode(13, 10);
}
WScript.Echo(ret);
