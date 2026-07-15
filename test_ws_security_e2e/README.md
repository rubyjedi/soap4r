# WS-Security e2e tests

Confirms `SOAP::WSSE::UsernameTokenFilter`, `SignatureFilter`, and
`EncryptionFilter` (`lib/soap/wssecurity.rb`) actually interoperate with a
real WS-Security implementation -- not just that they produce
plausible-looking XML.

## Why this directory, not `test/`

Same reasoning as `vendor_wsdl_e2e/` (see its own README): these tests need
a live network endpoint, so they're kept out of `test:deep`/`test:surface`'s
globs and given their own Rake task (`test:ws_security_e2e`) instead.

Unlike `vendor_wsdl_e2e`, *every* test here needs the live endpoint (there's
no local-fixture-only subset) -- the endpoint is a self-hosted Docker
container, not a third party, so there's no live-network-etiquette reason to
gate it behind an opt-in env var the way the NetSuite test is. Instead, each
test just checks reachability in `setup` and `omit`s itself if the server
isn't there, so a plain `rake test:ws_security_e2e` "just works" if the
server happens to be running, and cleanly no-ops (not fails) if it isn't.
Override the server location with `SOAP4R_TEST_WSSECURITY_URL` (default
`http://localhost:8080/swss`).

## What's being tested

All 9 endpoints of a real, live
[Bernardo-MG/spring-ws-security-soap-example](https://github.com/Bernardo-MG/spring-ws-security-soap-example)
instance (WSS4J and XWSS, Spring-WS's two WS-Security interceptor
implementations) -- unsecured, UsernameToken (plain/digest password x
WSS4J/XWSS), XML Signature (WSS4J/XWSS), and XML Encryption (WSS4J/XWSS).

This is a real, independent WS-Security implementation soap4r-ng has no
control over -- if soap4r's client produces spec-correct wire output, this
is where that gets proven, the same way `vendor_wsdl_e2e`'s vendored WSDLs
prove `wsdl2ruby.rb` against real production APIs rather than only this
project's own synthetic fixtures.

## Running the test server locally

The server lives in the sibling project `soap4r-ws-security-testbed`
(not vendored into this repo -- it's a full Java/Maven/Spring-WS
application, not a Ruby test fixture). See that project's own README for
how to build and run it; once it's listening on `localhost:8080`, these
tests pick it up automatically.

`test_ws_security_e2e/keys/swss-cert.{crt,key}.pem` are that project's own
test keystore's cert/private key, in PEM form -- a disposable, self-signed,
already-public 1024-bit RSA keypair used purely for local interop testing,
not a secret of any kind. Vendored here (unlike the server itself) since
they're small, Ruby-side test fixtures the client filters need directly.

## Running locally

```
rake test:ws_security_e2e                                    # default parser/HTTP backend
SOAP4R_PARSERS=libxmlparser rake test:ws_security_e2e         # under a specific XML parser
SOAP4R_HTTP_CLIENTS=net_http rake test:ws_security_e2e        # under a specific HTTP backend
SOAP4R_TEST_WSSECURITY_URL=http://localhost:9090/swss rake test:ws_security_e2e  # non-default server location
```
