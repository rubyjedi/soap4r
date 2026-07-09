# encoding: UTF-8
require 'helper'
require 'soap/netHttpClient'

module SOAP


# Covers SOAP::NetHttpClient#create_connection directly (via #send, since
# it's private) rather than through the full driver/streamHandler stack:
# HTTPStreamHandler only falls back to NetHttpClient when both httpclient
# and http-access2 fail to load, and this project's Gemfile always
# requires httpclient, so nothing else in the suite ever exercises this
# file. create_connection only builds and configures a Net::HTTP object
# (no #start call), so this is safe to test without a real network call
# or proxy server.
class TestNetHttpClient < Test::Unit::TestCase
  TARGET = URI.parse("http://target.example.com/")

  def test_proxy_with_credentials
    client = NetHttpClient.new("http://myuser:mypass@myproxy.example.com:8080")
    conn = client.send(:create_connection, TARGET)
    assert_equal("myproxy.example.com", conn.proxy_address)
    assert_equal(8080, conn.proxy_port)
    assert_equal("myuser", conn.proxy_user)
    assert_equal("mypass", conn.proxy_pass)
  end

  def test_proxy_without_credentials
    client = NetHttpClient.new("http://myproxy.example.com:8080")
    conn = client.send(:create_connection, TARGET)
    assert_equal("myproxy.example.com", conn.proxy_address)
    assert_equal(8080, conn.proxy_port)
    assert_nil(conn.proxy_user)
    assert_nil(conn.proxy_pass)
  end

  def test_no_proxy
    client = NetHttpClient.new
    conn = client.send(:create_connection, TARGET)
    assert_nil(conn.proxy_address)
  end
end


end
