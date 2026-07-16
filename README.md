# soap4r-ng
[![Gem Version](https://badge.fury.io/rb/soap4r-ng.svg)](http://badge.fury.io/rb/soap4r-ng)
[![GitHub version](https://badge.fury.io/gh/rubyjedi%2Fsoap4r.svg)](http://badge.fury.io/gh/rubyjedi%2Fsoap4r)
[![CI](https://github.com/rubyjedi/soap4r/actions/workflows/ci.yml/badge.svg)](https://github.com/rubyjedi/soap4r/actions/workflows/ci.yml)

#### Soap4R (as maintained by RubyJedi)
* Unit Tested to work under MRI Ruby **1.8.7** thru **4.0** -- yes, still 1.8.7! Every minor release in between (1.9.3, 2.0-2.7, 3.0-3.4) passes the full test suite, with a small, understood set of exceptions -- see "Known Test Suite Exceptions" below.
* Also runs under **JRuby** (9.4 and 10.1): 3 of the 5 XML parsers (Nokogiri, Oga, REXML) work correctly, with a handful of JRuby-engine-specific test exceptions (also documented below). `Ox` and `LibXML` have no viable JRuby-compatible gem available at all -- `ox` has never had a JRuby port, and the one and only `libxml-jruby` release is from 2010 and calls a JRuby API removed long ago.
* ***Five interchangeable XML Parser backends -- all fully functional***
    * **[Ox](https://github.com/ohler55/ox)**
    * **[Nokogiri](https://github.com/sparklemotion/nokogiri)**
    * **[Oga](https://github.com/YorickPeterse/oga)**
    * **[LibXML](https://github.com/xml4r/libxml-ruby)**
    * **REXML** (the built-in fallback, bundled with Ruby)
* ***Pluggable HTTP Client backends -- two of them opt-in***, see "HTTP Client Backends" below.
    * **[httpclient](https://github.com/nahi/httpclient)** (the default, strongly recommended)
    * **[curb](https://github.com/taf2/curb)** (opt-in)
    * **[faraday](https://github.com/lostisland/faraday)** (opt-in)
    * `SOAP::NetHttpClient` (stdlib `Net::HTTP` fallback, used only when none of the above are installed)
* ***Fully Operational Unit Test Suite***. NaHi's Unit Tests are astonishingly thorough, and have been instrumental in discovering issues that each new Ruby version brings up. Thanks to those Unit Tests, I'm **very** confident in the code quality of this fork.
* ***SOAP 1.2 support***, alongside the original SOAP 1.1 -- opt-in per driver, see "SOAP Version (1.1 vs 1.2)" below.
* ***WS-Security support*** -- UsernameToken (plain/digest), XML Signature, and XML Encryption, verified against real WSS4J and XWSS servers. See "WS-Security" below.

#### How to Install 
##### (Bundler Gemfile / GitHub Hosted)
```
## Performance Boosting Gems -- soap4r-ng uses whichever of these are available,
## in priority order: Ox, then Nokogiri, then LibXML, then Oga, then REXML.
gem 'ox'
gem 'nokogiri'
gem 'libxml-ruby'
gem 'oga'
## REXML is the last-resort fallback -- it's bundled with Ruby itself, but
## Ruby 3.0+ demoted it (and webrick) from the standard library to an
## optional bundled gem, so add them explicitly or you'll hit a LoadError
## at runtime:
gem 'rexml'
gem 'webrick'
## Ruby 4.0+ did the same to logger:
gem 'logger'

gem 'httpclient' # Strongly recommended. See "HTTP Client Backends" below for the Net::HTTP fallback's limitations.
## curb and faraday are additional, opt-in HTTP client backends -- not
## needed unless you specifically want one of them; see "HTTP Client
## Backends" below.

gem 'soap4r-ng', :git=>'https://github.com/rubyjedi/soap4r.git', :branch=>"master"
```
##### Standard Ruby Gem
```
gem install soap4r-ng
```

#### Gem Version Pinning by Ruby Version
If you're on a legacy Ruby and updating soap4r-ng, here's exactly what each of
the 5 parsers needs. This table only covers what changes between Ruby
versions -- the *why* behind each pin (usually "the current release of this
gem needs a newer Ruby than this, and there's no older release to fall back
on") is documented alongside the real thing, in this project's own
`Gemfile`.

There's an asymmetry worth knowing up front: **older Rubies need parser gems
capped to an old version**, while **Ruby 3.0+ needs a couple of gems added
explicitly that used to come for free**. It's not simply "newer Ruby needs
less" -- it needs *different* things.

| Ruby version | nokogiri | ox | oga (via ruby-ll) | libxml-ruby | test-unit | rexml / webrick | logger |
|---|---|---|---|---|---|---|---|
| &le; 1.8 (1.8.7) | `~> 1.5.11` | `~> 2.4.5` | **not available** -- never installed, gracefully falls through to the next parser | `~> 2.8.0` | `~> 1.2.3` (also needs `hoe '1.5.1'` and `json_pure '~> 1.7.6'` pinned, or `bundle install` itself fails) | implicit, no gem needed | implicit |
| 1.9.x | `~> 1.6.6` | `~> 2.4.5` | `ruby-ll '~> 2.1.2'` pinned | `~> 2.8.0` | `~> 3.0.5` | implicit | implicit |
| 2.0.x | `~> 1.6.6` | `~> 2.4.5` | `ruby-ll '~> 2.1.2'` pinned | `~> 3.1.0` | unconstrained | implicit | implicit |
| 2.1.x | `~> 1.6.6` | `~> 2.4.5` | unconstrained | `~> 3.1.0` | unconstrained | implicit | implicit |
| 2.2.x | `~> 1.6.6` | unconstrained | unconstrained | `~> 3.1.0` | unconstrained | implicit | implicit |
| 2.3.x -- 2.9.x | unconstrained | unconstrained | unconstrained | `~> 3.1.0` | unconstrained | implicit | implicit |
| 3.0.x -- 3.9.x | unconstrained | unconstrained | unconstrained | `~> 3.1.0` | unconstrained | **must add explicitly** | implicit |
| 4.0.x and up | unconstrained | unconstrained | unconstrained | `~> 3.1.0` | unconstrained | must add explicitly | **must add explicitly** |

"Unconstrained" means just `gem 'nokogiri'` with no version -- Bundler picks
whatever release actually supports the Ruby you're running. "Must add
explicitly" means the gem is a real runtime requirement on that Ruby version
(`rexml`/`webrick` were demoted from the standard library to optional bundled
gems in Ruby 3.0; `logger` followed in Ruby 4.0) -- without it you'll hit a
`LoadError` the first time that code path runs, not at `bundle install` time.

**JRuby** is a separate axis from the table above. `ox` and `libxml-ruby`
have no working JRuby-compatible gem at all (`ox` has never had a JRuby port;
`libxml-jruby`'s one and only release is from 2010 and calls a since-removed
JRuby API) -- both parsers gracefully report unavailable rather than
crashing. `nokogiri`, `oga`, and `rexml` all work normally. `byebug` and
`pry-byebug` (dev-only debugging aids, not required to run anything) are
skipped entirely on JRuby since their C extension needs MRI's `ruby.h`.

#### HTTP Client Backends
Like the XML parsers above, the HTTP client is pluggable: `lib/soap/streamHandler.rb`
picks one at load time via `lib/soap/httpbackend.rb`, using the exact same
pattern as `SOAP4R_PARSERS` (`lib/xsd/xmlparser.rb`) -- a hardcoded
preference order, overridable with an environment variable, so a new backend
is a drop-in file rather than a change to library code.

* **[httpclient](https://github.com/nahi/httpclient)** -- the default and
  strongly recommended backend. Fully featured: proxying, basic/digest auth,
  cookies, SSL/TLS configuration, request/response filters. (Formerly named
  `http-access2`; see CHANGELOG.md if you need that old adapter.)
* **[curb](https://github.com/taf2/curb)** -- libcurl bindings. Opt-in (see
  below), needs system `libcurl-dev` at compile time. Supports proxying,
  SSL/TLS config (ca_file, client cert/key, cipher-list restriction), and
  basic/digest WWW-Authenticate auth. No cookies or request/response
  filters, and no `ssl_config.verify_callback` (libcurl's C API exposes no
  per-certificate Ruby callback hook). No JRuby port; gated to Ruby >= 2.4.
* **[faraday](https://github.com/lostisland/faraday)** -- gated to Ruby >= 2.6
  (see CHANGELOG.md for why). Has its own adapter system underneath our
  backend selection, defaulting to `:net_http` and overridable with
  `SOAP4R_FARADAY_ADAPTER` (e.g. `SOAP4R_FARADAY_ADAPTER=typhoeus`) -- a
  second, independent knob layered under `SOAP4R_HTTP_CLIENTS`. Opt-in (see
  below). Supports proxying, basic auth (sent proactively via a
  manually-built header), and SSL/TLS config (ca_file, client cert/key as
  file paths). No challenge-response auth, cookies, request/response
  filters, or `verify_callback`. Cipher-list restriction passes through to
  the active adapter, but `:typhoeus` silently ignores it (an upstream gap,
  not this bridge). `SOAP4R_FARADAY_ADAPTER=patron` also works for ordinary
  requests but isn't part of the automated test matrix (see "Known Test
  Suite Exceptions" below).
* **`SOAP::NetHttpClient`** -- this project's own wrapper around stdlib
  `Net::HTTP`, used only when none of the above are installed. No
  basic/digest auth, cookies, or request/response filters. A reasonable
  fallback for simple unauthenticated SOAP calls when you can't add a gem
  dependency, but `httpclient` is what most of this library's real-world
  testing assumes.

Force a specific backend with:
```
SOAP4R_HTTP_CLIENTS=net_http bundle exec rake test:deep
```
Valid names are `httpclient`, `curb`, `faraday`, and `net_http`, matching
the files under `lib/soap/httpbackend/`. `curb` and `faraday` are opt-in
Bundler groups: `BUNDLE_WITH="http_curb:http_faraday" bundle install`
(an env var, not `bundle config set with "..."` -- see CHANGELOG.md).

CI runs the full suite against `net_http`, `curb`, and `faraday` too
(single-parser each -- this is about the HTTP layer, not XML parsing).
Faraday runs with the `:typhoeus` adapter specifically (real correctness
check plus the most-used adapter in practice); `:patron` was tried and
dropped from CI (real upstream bug, not ours -- see "Known Test Suite
Exceptions" below). Full backstory on the backend rollout (wiredump-parity
work, TLS-trust defaults, per-backend test coverage decisions) is in
CHANGELOG.md.

#### SOAP Version (1.1 vs 1.2)
soap4r-ng defaults to SOAP 1.1 (unchanged behavior). Opt into SOAP 1.2 per
driver:
```ruby
driver.soap_version = SOAP::SOAPVersion1_2
```
This switches the envelope namespace, the header block's addressing
attribute (1.1's `actor` becomes 1.2's `role`, plus the 1.2-only `relay`
attribute), the fault model (1.2's `Code`/`Reason`/`Node`/`Role`/`Detail`
instead of 1.1's `faultcode`/`faultstring`/`faultactor`/`detail`), and the
HTTP transport (`application/soap+xml` with the SOAPAction folded into the
Content-Type's `action` parameter, instead of 1.1's separate `SOAPAction`
header) -- all per spec. WSDL binding parsing recognizes the SOAP 1.2
binding namespace alongside 1.1's. SOAP-with-Attachments (MIME multipart)
also honors whichever version is set for the parts' media type, with one
pragmatic exception: multipart requests still send the legacy `SOAPAction`
header even under 1.2, since action-placement for multipart+1.2 combined
isn't settled by any spec and real-world use of that combination is rare.

#### WS-Security
`lib/soap/wssecurity.rb` adds `SOAP::WSSE::UsernameTokenFilter`,
`SignatureFilter`, and `EncryptionFilter`, plugging into the same
envelope-level filter chain every HTTP backend already shares:
```ruby
driver.filterchain.add(SOAP::WSSE::UsernameTokenFilter.new(user, pass, :digest => true))
driver.filterchain.add(SOAP::WSSE::SignatureFilter.new(key_path, cert_path))
driver.filterchain.add(SOAP::WSSE::EncryptionFilter.new(cert_path))
```
* **UsernameTokenFilter** -- WS-Security UsernameToken Profile 1.0/1.1,
  plain (`PasswordText`) or digested (`PasswordDigest`: nonce + timestamp +
  SHA-1) passwords.
* **SignatureFilter** -- XML Signature over the SOAP Body (exclusive C14N,
  RSA-SHA1), the shape a typical WSS4J/XWSS default configuration expects.
  Also verifies signed responses (`on_inbound`), checking every signed
  `Reference`'s digest against a configurable trusted certificate.
* **EncryptionFilter** -- XML Encryption (AES-128-CBC content encryption,
  RSA-OAEP key transport), including decrypting encrypted responses
  (`on_inbound`).

Both `SignatureFilter` and `EncryptionFilter` need Nokogiri specifically
(the only one of the five supported XML parsers with a correct C14N
implementation -- see the file-level comment in `lib/soap/wssecurity.rb`
for why libxml-ruby's was rejected after surfacing a real namespace-node
bug). `UsernameTokenFilter` has no such dependency. All three were verified
against a real, self-hosted WSS4J/XWSS test server (see
`test_ws_security_e2e/README.md`), not just synthetic fixtures.

#### Known Test Suite Exceptions
Running `rake test:deep` across the full version matrix surfaces a small,
understood set of failures that aren't soap4r-ng bugs -- either something
the target Ruby/engine genuinely can't do, or a test checking something too
environment-specific to be fair. Documented here so they don't get mistaken
for regressions; full root-cause writeups are in CHANGELOG.md.

* **Ruby 1.8.7** -- 3 errors from `Kernel#singleton_class` not existing
  until Ruby 1.9.2 (CANTFIX), plus the CGI-based tests
  (`test_calc_cgi`, `test_authheader_cgi`) and two collateral WSDL tests
  failing from a not-fully-root-caused WEBrick/CGI-subprocess environment
  issue.
* **Ruby 2.4.10, 2.5.9, `SOAP4R_HTTP_CLIENTS=curb`** -- `test_ca_verification`/
  `test_ciphers` fail from those Docker images' older libcurl/OpenSSL
  (CANTFIX, environment-specific, not a soap4r-ng/curb bug).
* **Ruby 3.0.7, 3.1.7, 3.2.11** -- `test_exception` fails because it compares
  a live `Test::Unit::TestCase#inspect` dump that renders differently across
  this patch-version range (WONTFIX, not under this library's control).
* **JRuby** (9.4.15.0, 10.1.0.0) -- 13 confirmed environment/engine
  differences (integer parsing, `ENV` object model, SSL socket bridge,
  backtrace formatting), all CANTFIX/upstream. A handful of other JRuby-only
  failures were a real, fixable bug (`SOAP::Mapping.fault2exception` assumed
  a non-nil `.backtrace`) -- fixed with a nil-guard.
* **`SOAP4R_HTTP_CLIENTS=faraday SOAP4R_FARADAY_ADAPTER=patron`** -- not run
  in CI; the CGI-based tests fail with `Patron::Aborted: Callback aborted`,
  root-caused to patron itself, not this project's code (CANTFIX).

#### How to Use
* [NaHi's Original documentation](https://web.archive.org/web/20101212040735/http://dev.ctor.org/soap4r/wiki/) -- the authoritative reference material is still available through the Wayback Machine, thankfully!
* [Soap4R-NG Website](http://rubyjedi.github.io/soap4r/) -- My own attempt at incorporating and modernizing the above into GitHub Pages -- still a work in progress at this time.

#### How to Get a Speed Boost : Use Nokogiri or Ox, not REXML
Be sure to have Nokogiri or Ox available in your Gemset. Soap4R-ng will find and use what's available (Ox has highest precedence, then Nokogiri, then LibXML, then Oga, falling back to REXML as the last resort if needed).

I personally recommend **Nokogiri** as the best performing, most flexible parser at this time, as it handles "special characters" like HTML ampersand-escaped characters internally. Ox needs **htmlentities** as a fallback on Ruby 1.8.7 (stuck on the old Ox 2.4.5, which only decodes the 5 basic XML entities) and on Ruby 2.2.x-2.6.x (stuck on Ox 2.14.14, which segfaults on complex documents without it -- see CHANGELOG.md). Ruby 1.9.3-2.1.x and Ruby >= 2.7 both resolve an Ox release that decodes entities natively and safely, so htmlentities is dead weight there.

If you know your incoming XML is "clean", Ox is a really great alternative.

**LibXML** used to have a real bug: its SAX binding silently drops namespace prefixes on attributes, which broke type-casting for anything relying on `xsi:type`, `xsi:nil`, or `xml:lang`. That's been fixed by switching the parser over to libxml-ruby's `XML::Reader` API instead, and it now passes the exact same test suite as the other four parsers.

#### Project Motivation

I have a personal vested interest in making this the ***fastest, most reliable*** successor to [NaHi's original Soap4R library](https://github.com/nahi/soap4r), and in maintaining and documenting **Soap4R** to the best of my reasonably expected ability.

Soap4R has received a less-than-stellar reputation amongst the Ruby Community for far too long; and I've grown tired of seeing shoddy advice floating around to abandon **Soap4R** in favor of other SOAP Implementations. That's just nonsense -- especially when you're faced with the challenge of updating large, already-written, revenue-generating systems.

IMHO, NaHi did a freaking brilliant job with **Soap4R**. The code is tight, the Unit Tests are astonishingly comprehensive, and -- aside from finding someone willing to invest time to carry **Soap4R** forward -- there's really no good reason why **Soap4R** should be so neglected.

In fact, I'd much prefer spending time forward-porting **Soap4R** to keep this known-good foundation library going, versus taking on the risky task of migrating already-written applications to a completely new SOAP implementation. Along the way in this journey, I'm adding support for newer XML Parsers like **[Ox](https://github.com/ohler55/ox)** (which is screaming fast, btw!) and **[Nokogiri](https://github.com/sparklemotion/nokogiri)**.

#### Why Name This "Soap4R-ng" ?
As **[felipec/soap4r](https://github.com/felipec/soap4r)** (now **[soap2r](https://github.com/felipec/soap4r)**) pointed out upon renaming his fork to **soap2r** , there is a LOT of competition to uniquely name the a "successor" to the original Soap4R. **soap2r** came into being because **"[Soap5R](https://github.com/aforward/soap4r)"** had already been claimed. :-)

#### Other Soap4R Forks/Networks of Interest
 * [nahi/soap4r](https://github.com/nahi/soap4r) - The original Soap4R by NaHi
 * [spox/soap4r-spox](https://github.com//spox/soap4r-spox) - One of the first Ruby 1.9-compatible forks
 * [felipec/soap4r](https://github.com//felipec/soap4r) - **Soap2R**

#### Testing or Contributing
Diving into the Source? Sure, I can always use more eyes to improve the code quality. Welcome aboard!

I assume you know how to check out the Git Repository, set up **rvm** or equivalent environment, and run **Bundler** to pull in the suggested Gems. From there, do a **rake test:surface** to run the smaller set of Unit Tests; or **rake test:deep** to run the complete set of Unit Tests.
