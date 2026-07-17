# WS-Security e2e tests

Confirms `SOAP::WSSE::UsernameTokenFilter`, `SignatureFilter`, and
`EncryptionFilter` (`lib/soap/wssecurity.rb`) actually interoperate with
real, independent WS-Security implementations -- not just that they
produce plausible-looking XML.

## Why this directory, not `test/`

Same reasoning as `vendor_wsdl_e2e/` (see its own README): these tests need
a live network endpoint, so they're kept out of `test:deep`/`test:surface`'s
globs and given their own Rake task (`test:ws_security_e2e`) instead.

Unlike `vendor_wsdl_e2e`, *every* test here needs a live endpoint (there's
no local-fixture-only subset) -- each endpoint is a self-hosted Docker
container, not a third party, so there's no live-network-etiquette reason to
gate any of it behind an opt-in env var the way the NetSuite test is.
Instead, each file checks reachability of its own server in `setup` and
`omit`s itself if that server isn't there, so a plain `rake
test:ws_security_e2e` "just works" with whichever of the four servers
happen to be running, and cleanly no-ops (not fails) for whichever aren't.
The Rake task itself (`Rakefile`) globs `test_ws_security_e2e/test_*.rb`,
so this is genuinely four independent test files, not four suites forced
to live or die together.

## What's being tested

Four real, live, independently-implemented WS-Security stacks, each in its
own file, each targeting the corresponding engine in the sibling
`soap4r-ws-security-testbed` project:

| File | Engine | Stack | Server URL env var (default) |
| --- | --- | --- | --- |
| `test_ws_security_bernardo.rb` | bernardo-mg | Spring-WS + WSS4J/XWSS | `SOAP4R_TEST_WSSECURITY_URL` (`http://localhost:8080/swss`) |
| `test_ws_security_cxf.rb` | rub-nds-cxf | Apache CXF's own native WSS4J interceptors | `SOAP4R_TEST_WSSECURITY_CXF_URL` (`http://localhost:8081`) |
| `test_ws_security_metro.rb` | rub-nds-metro | Metro/WSIT, WS-SecurityPolicy-driven | `SOAP4R_TEST_WSSECURITY_METRO_URL` (`http://localhost:8082`) |
| `test_ws_security_axis2.rb` | rub-nds-axis2 | Axis2 + Rampart, WS-SecurityPolicy-driven | `SOAP4R_TEST_WSSECURITY_AXIS2_URL` (`http://localhost:8083`) |

- **bernardo-mg**: all 9 endpoints -- unsecured, UsernameToken (plain/digest
  password x WSS4J/XWSS), XML Signature (WSS4J/XWSS), XML Encryption
  (WSS4J/XWSS).
- **rub-nds-cxf**: all 10 endpoints -- unsecured, Signature-only,
  Timestamp-only, Encryption-only, and every combination of the three
  (`encsign`, `encts`, `tssign`, `enctssign`), plus SOAP 1.2 variants of
  Signature-only and Timestamp-only (`sign12`, `ts12`).
- **rub-nds-metro**: its one endpoint, combined Encrypt+Sign
  (WS-SecurityPolicy `sp:EncryptBeforeSigning`).
- **rub-nds-axis2**: combined Encrypt+Sign, both SOAP 1.1 and SOAP 1.2
  (`axis2-encsign`'s two auto-generated ports -- Axis2 is the only engine
  here that auto-generates a SOAP 1.2 port for every deployed service,
  which is why it's the one used to prove the SOAP 1.2 fix end to end for
  the combined path). Deliberately **not** testing `axis2-ut`/
  `axis2-ut-digest` (UsernameToken) here: both hit a genuine Rampart
  1.8.0/WSS4J 3.0.3 version-mismatch bug on the server side (see the
  testbed's own CHANGELOG.md), not soap4r-ng behavior worth locking into
  this project's formal suite as "expected."

Each is a real, independent WS-Security implementation soap4r-ng has no
control over -- if soap4r's client produces spec-correct wire output, this
is where that gets proven, the same way `vendor_wsdl_e2e`'s vendored WSDLs
prove `wsdl2ruby.rb` against real production APIs rather than only this
project's own synthetic fixtures. Using four independently-implemented
stacks (Spring-WS, CXF's native WSS4J integration, Metro/WSIT, Axis2/
Rampart) rather than just one is what actually caught the real bugs
documented in CHANGELOG.md ("WS-Security: combined sign+encrypt fix",
"WS-Security: SOAP 1.2 support", "WS-Security: two real Ruby 1.8.7 bugs
found and fixed") -- a single implementation's own quirks/leniency can
mask a real interop bug that a second, differently-built one won't.

## Running the test servers locally

All four servers live in the sibling project `soap4r-ws-security-testbed`
(not vendored into this repo -- full Java/Maven applications, not Ruby
test fixtures). See that project's own README for how to build and run
each; once they're listening on their default ports (8080-8083), these
tests pick them up automatically. Any subset can be running at once --
each file only omits its own tests if its own server isn't reachable.

`test_ws_security_e2e/keys/` holds each engine's own test keystore's
cert/private key, in PEM form -- disposable, self-signed, already-public
keypairs used purely for local interop testing, not secrets of any kind.
Vendored here (unlike the servers themselves) since they're small,
Ruby-side test fixtures the client filters need directly:

- `keys/swss-cert.{crt,key}.pem` -- bernardo-mg's shared client/server
  keypair (this server signs/encrypts responses with the *same* identity
  the client uses, unlike the other three).
- `keys/cxf/`, `keys/metro/`, `keys/axis2/` -- each has its own
  `client.{key,crt}.pem` (this suite's own identity, for signing/
  encrypting requests and decrypting responses) and `server.crt.pem`
  (that engine's server identity, for verifying/encrypting-to what it
  sends back) -- these three engines use separate client and server
  identities, unlike bernardo-mg.

## Running locally

```
rake test:ws_security_e2e                                    # every reachable server, default parser/HTTP backend
SOAP4R_PARSERS=libxmlparser rake test:ws_security_e2e         # under a specific XML parser
SOAP4R_HTTP_CLIENTS=net_http rake test:ws_security_e2e        # under a specific HTTP backend
SOAP4R_TEST_WSSECURITY_URL=http://localhost:9090/swss rake test:ws_security_e2e         # non-default bernardo-mg location
SOAP4R_TEST_WSSECURITY_CXF_URL=http://localhost:9091 rake test:ws_security_e2e          # non-default rub-nds-cxf location
SOAP4R_TEST_WSSECURITY_METRO_URL=http://localhost:9092 rake test:ws_security_e2e        # non-default rub-nds-metro location
SOAP4R_TEST_WSSECURITY_AXIS2_URL=http://localhost:9093 rake test:ws_security_e2e        # non-default rub-nds-axis2 location
```

Ruby `test-unit`'s own test runner reports each server's tests as omitted
(not failed, not passed) when that server isn't reachable -- check the
run's own summary line if you expect a particular engine's tests to have
actually run rather than been skipped.
