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
* ***Fully Operational Unit Test Suite***. NaHi's Unit Tests are astonishingly thorough, and have been instrumental in discovering issues that each new Ruby version brings up. Thanks to those Unit Tests, I'm **very** confident in the code quality of this fork.

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
  cookies, SSL/TLS configuration, request/response filters (used for things
  like cookie handling -- see `test/soap/test_cookie.rb`). Formerly named
  `http-access2` (same author, Hiroaki "NaHi" Nakamura, renamed it years
  ago) -- that old name is no longer published on RubyGems.org at all and
  was retired from this project's own backend cascade for the same reason;
  see git history if you need the adapter that used to sit here.
* **[curb](https://github.com/taf2/curb)** -- libcurl bindings. Opt-in (see
  below): needs a system `libcurl-dev` present at compile time, unlike every
  other backend here. Supports proxying, SSL/TLS configuration (ca_file,
  client cert/key, and cipher-list restriction -- the last of these has no
  dedicated setter at all on `Curl::Easy`, despite libcurl itself supporting
  it; reached via `#setopt(Curl::CURLOPT_SSL_CIPHER_LIST, ...)` instead),
  and -- via libcurl's own challenge negotiation -- both basic and digest
  WWW-Authenticate auth (`test/soap/auth/test_basic.rb` and
  `test_digest.rb` both pass against it unmodified). Cookies and
  request/response filters are not wired up (same limitation as
  `SOAP::NetHttpClient` below). No JRuby port at all (native extension), and
  not validated below Ruby 2.2. **No `ssl_config.verify_callback` support**
  -- libcurl's C API exposes no per-certificate Ruby callback hook at all,
  so this is a hard architectural gap, not something left unwired; see
  `test/soap/ssl/test_ssl.rb`'s `test_verification`/`test_property` for what
  that means for test coverage.
* **[faraday](https://github.com/lostisland/faraday)** -- Faraday is itself
  pluggable underneath our own backend selection: it has its own adapter
  system, defaulting to `:net_http` and overridable with
  `SOAP4R_FARADAY_ADAPTER` (e.g. `SOAP4R_FARADAY_ADAPTER=typhoeus`) -- a
  second, independent config knob layered under `SOAP4R_HTTP_CLIENTS`, not a
  replacement for it. Opt-in (see below). Supports proxying, basic auth
  (sent proactively via a manually-built `Authorization` header, since
  Faraday's core has no bundled auth middleware), and SSL/TLS configuration
  (ca_file, client cert/key -- passed as file paths, since confirmed
  empirically that at least the `:typhoeus` adapter rejects in-memory
  `OpenSSL::X509::Certificate`/`OpenSSL::PKey::RSA` objects despite
  `Faraday::SSLOptions` documenting them as accepted). Does **not** support
  challenge-response (WWW-Authenticate) auth, cookies, request/response
  filters, or `ssl_config.verify_callback` (no adapter Faraday supports
  exposes a per-certificate Ruby callback either -- same underlying
  limitation as libcurl-based backends generally), since none of those have
  a core-Faraday equivalent that would work uniformly across every adapter.
  Cipher-list restriction is passed through to whichever adapter is active,
  but confirmed empirically that `:typhoeus` silently ignores it (Faraday's
  own `faraday-typhoeus` adapter never forwards `ciphers` to `ethon`'s
  `ssl_cipher_list` option at all) -- a real gap in that third-party
  adapter, not this bridge.
  `SOAP4R_FARADAY_ADAPTER=patron` also works for ordinary requests, but see
  the note below -- it isn't part of the automated test matrix.
* **`SOAP::NetHttpClient`** -- this project's own wrapper around stdlib
  `Net::HTTP`, used only when none of the above are installed. It does
  **not** support basic/digest auth, cookies, or request/response filters
  (all raise `NotImplementedError`, or are silently inert for filters) --
  these were never wired up for this backend. It's a reasonable fallback for
  simple unauthenticated SOAP calls when you can't add a gem dependency, but
  `httpclient` is what most of this library's real-world testing and feature
  support assumes.

Force a specific backend (e.g. to debug something backend-specific, or to
run the test suite against a backend other than the default) with:
```
SOAP4R_HTTP_CLIENTS=net_http bundle exec rake test:deep
```
Valid names are `httpclient`, `curb`, `faraday`, and `net_http`, matching
the files under `lib/soap/httpbackend/`. `curb` and
`faraday` are opt-in Bundler groups (`bundle config set with "http_curb
http_faraday"` before `bundle install`) rather than main-Gemfile
dependencies, since curb in particular needs a system library present just
to compile -- installing it unconditionally would break `bundle install` for
every contributor who never touches this backend.

CI runs the full suite against `net_http`, `curb`, and `faraday` too
(single-parser each, since this is about the HTTP layer, not XML parsing)
precisely because, before `SOAP4R_HTTP_CLIENTS` existed, nothing in the test
suite could ever actually reach the `net_http` fallback -- this project's own
Gemfile always installed `httpclient`, so the fallback cascade never had a
reason to fall through. Making backends independently selectable surfaced
(and fixed) real bugs in the process: `SOAP::NetHttpClient`'s wiredump output
duplicated request/response bodies and was missing the raw
request-line/header block entirely, corrupting any test or tool that parsed
`wiredump_dev` output. Faraday's own adapter list is deliberately *not*
swept exhaustively -- our own bridge code (`lib/soap/faradayClient.rb`) is
what we're testing, and sweeping every adapter Faraday itself supports would
mostly re-test Faraday's own correctness rather than anything specific to
soap4r-ng. Faraday's *default* sub-adapter (`:net_http`) doesn't get its own
CI step at all, for the same reason: it would just re-exercise stdlib
`Net::HTTP`, which the `net_http` backend above already covers end-to-end --
the whole point of carrying Faraday here is reaching backends we have no
native adapter for. So CI runs Faraday with `:typhoeus` (libcurl-based via
`ethon`/FFI): it doubles as this bridge's real correctness check
(proxy/SSL/timeout config plumbing against a transport genuinely different
from the other four) and a real capability, since it's also the adapter
people actually reach for in practice -- 28 reverse dependencies on
RubyGems versus, say, `faraday-patron`'s 3, per [Ruby Toolbox](https://www.ruby-toolbox.com/projects/faraday-typhoeus).

`:patron` was tried as a second spot-check adapter too and dropped: two CGI
tests fail under it with `Patron::Aborted: Callback aborted`, root-caused to
patron itself rather than this bridge or Faraday -- reproduced with a bare
`Patron::Session#post` against the exact same server, no soap4r-ng or
Faraday code involved at all. Not reproducible with curb (also
libcurl-based) or `:typhoeus` above. The Gemfile still installs it
(`SOAP4R_FARADAY_ADAPTER=patron` works for ordinary requests), it's just not
part of the automated matrix, since there's no fix available on our end for
an upstream bug -- see "Known Test Suite Exceptions" below.

**Test parity across backends**: several tests (WSDL-driven codegen
round-trips, request-envelope assertions, ASP.NET-handler interop -- see
e.g. `test/wsdl/rpc/test_rpc_lit.rb`, `test/wsdl/qualified/`,
`test/soap/test_no_indent.rb`) used to be gated to `httpclient` only,
because they parse `wiredump_dev` output and were written assuming its
specific block layout. That layout turned out to already be backend-neutral
*by design* once `NetHttpClient`/`CurbClient`/`FaradayClient` were all built
to mirror it (see the wiredump-format work above) -- confirmed by simply
removing the gates and running the suite, which passed unmodified under
every backend. The duplicated parsing logic across those files is now
consolidated into `TestUtil.parse_wiredump_request_body`/
`parse_wiredump_response_body` (`test/testutil.rb`), documented there as the
one place a future backend's format quirks would need handling, if one ever
had them.

`test/soap/ssl/test_ssl.rb` similarly now runs its SSL config-loading
coverage against every SSL-capable backend (httpclient, curb, faraday),
not just httpclient -- `test_ca_verification` (ca_file-based verification
success/failure, backend-neutral) and `test_ciphers` (rewritten to expect
each backend's own real exception class, empirically confirmed rather than
guessed: `OpenSSL::SSL::SSLError` for httpclient, `Curl::Err::CurlError`
for curb, `Faraday::Error` for Faraday -- test-unit's `assert_raise` wants
an *exact* class match, unlike plain Ruby `rescue`, so backend-specific
subclasses are caught via `rescue`, matching this file's existing
convention). `test_options`/`test_verification`/`test_property` stay
httpclient-only: they're built around `ssl_config.verify_callback`, and
neither libcurl-based backend (curb, or Faraday riding on typhoeus/patron)
exposes a per-certificate Ruby callback hook at all -- confirmed against
both libraries' public APIs, not assumed. That's the one piece of "full
parity" across backends that isn't achievable without a capability that
simply doesn't exist outside OpenSSL-native clients (httpclient, stdlib
`Net::HTTP`).

**A note on TLS trust for the `httpclient` backend**: `httpclient`'s
`SSLConfig` doesn't trust your system's CA bundle unless told to -- left
unconfigured, it lazily falls back to its own gem-vendored `cacert.pem`
snapshot, which can go stale relative to a real server's certificate chain as
CAs rotate their intermediates (confirmed directly: a real Let's
Encrypt-signed endpoint failed verification against an older bundled
snapshot while verifying fine against the host's own, actively-maintained CA
bundle). `lib/soap/httpbackend/httpclient.rb` calls `set_default_paths` on
every `httpclient` connection's `ssl_config` by default now, which defers to
whatever CA store OpenSSL was actually built to trust on your platform --
portable across Debian/RHEL/Alpine/etc, and layered *before* any
`ssl_config.ca_file`/`ca_path`/`cert_store` you set yourself, so explicit
configuration still works exactly as before. `SOAP::NetHttpClient` was never
affected by this -- it has no SSL configuration surface of its own and
simply defers to Ruby's own stdlib `Net::HTTP`/OpenSSL defaults, which
already trust the system store without any help.

#### Known Test Suite Exceptions
Running `rake test:deep` (the complete suite) across the full version matrix
surfaces a small, understood set of failures that aren't soap4r-ng bugs --
they're either something the target Ruby genuinely can't do, or a test that's
checking something too environment-specific to be a fair test. Documented
here so they don't get mistaken for regressions:

CI runs every version inside the same Docker image used for local
validation (official `ruby:X.Y.Z` / `jruby:X.Y.Z.W` images where one exists;
a from-source `rbenv` build on Debian bullseye for 1.9.3 and 2.0.0, whose
official Docker Hub images are permanently unpullable -- every tag in both
lines was published in the long-deprecated Docker manifest v1 schema; a
from-source build against a vendored OpenSSL 1.0.2u for 1.8.7, which has no
official image at all). Matching the exact environment means a clean local
run and a clean CI run are the same claim -- there's no separate "works on
my machine" environment for version-specific gotchas to hide in.

* **Ruby 1.8.7** -- two separate issues, neither a soap4r-ng regression:
    * 3 errors (`test_time`, `test_time_ivar`, `test_time_subclass` in
      `marshaltestlib.rb`) from `Kernel#singleton_class`, which doesn't exist
      until Ruby 1.9.2. **CANTFIX**: the method is absent on that Ruby, full
      stop.
    * The CGI-based tests (`test_calc_cgi`, `test_authheader_cgi`) fail with
      `SOAP::ResponseFormatError: ... Internal Server Error`. Root-caused
      partway: WEBrick's `CGIHandler` wipes the spawned CGI subprocess's
      entire environment before exec'ing it, so `logger-application` and
      `webrick` need forwarding via a raw `-I` load-path flag (already fixed,
      in `test/soap/calc/test_calc_cgi.rb` and
      `test/soap/header/test_authheader_cgi.rb`). That forwarding alone
      wasn't enough on 1.8.7 specifically: the spawned
      subprocess still hits `NameError: undefined local variable or method
      'logger'` inside `lib/soap/rpc/cgistub.rb#run`, even though
      `Logger::Application#logger` is a real public method and a minimal
      reproduction of the exact same class hierarchy (`Logger::Application`
      combined with `include SOAP` and `include WEBrick`) works fine in
      isolation.
      **Not fully root-caused** -- something specific to the real
      `CGIStub`/`AuthHeaderPortServer`/`CalcServer` class graph, only
      reproducible via the actual spawned-CGI-subprocess path, not a
      simplified one. Narrow enough in scope (2 of ~330 tests, both CGI
      smoke tests rather than core library behavior) that it wasn't worth
      further chasing this round; flagged here rather than silently
      swallowed by `continue-on-error`.
    * Collateral damage from the CGI issue above: `test_nil_attribute` and
      `test_wsdl_with_map` (`test/wsdl/document/test_rpc.rb`) intermittently
      receive a garbage `dateTime` value (`XSD::ValueSpaceError`, a string
      that isn't a valid `dateTime` at all) when run as part of the full
      `rake test:deep` suite, but pass cleanly every time when that same
      file is run in isolation (`SCOPE=wsdl/document`). Confirmed this is
      state leaking from a still-lingering CGI subprocess/WEBrick server
      thread earlier in the same single-process test run (the CGI tests
      execute well before this file alphabetically), not a genuine 1.8.7
      `Date`/`DateTime` arithmetic bug -- ruled that out directly, since
      `XSDDateTimeImpl#screen_data`'s `Time` branch produces a correct
      result in isolation. **Not independently fixable**: same underlying
      CGI/WEBrick environment fragility as the bullet above, just showing
      up on a different, unrelated test as collateral rather than on the
      CGI test itself.
* **Ruby 3.0.7, 3.1.7, 3.2.11** -- 1 failure in `test_exception`
  (`test/soap/marshal/marshaltestlib.rb`), which marshals an exception whose
  `.message` embeds a live `#inspect` dump of the entire running
  `Test::Unit::TestCase` (memory addresses, internal test-framework state and
  all). **WONTFIX**: confirmed via a minimal reproduction that soap4r-ng's own
  exception-marshaling code round-trips correctly; the test itself is
  fragile because it's comparing volatile process/framework internals that
  happen to render differently across this narrow range of Ruby patch
  versions, not anything under this library's control.
* **JRuby** (9.4.15.0 and 10.1.0.0, identical on both) -- 13 confirmed
  environment-specific items, none of them soap4r-ng bugs:
    * 7 `XSD::ValueSpaceError` tests (`test_SOAPInteger`, `test_XSDInteger`,
      and friends) -- JRuby's `Kernel#Integer()` silently stops validating
      trailing garbage characters (e.g. a trailing `.`) once the digit count
      gets long enough, where MRI correctly raises `ArgumentError` regardless
      of length. **CANTFIX**: a JRuby core-method behavior difference.
    * `test_singleton` (`marshaltestlib.rb`) -- expects marshaling `ENV` to
      raise `TypeError` (Ruby singleton objects can't be dumped). JRuby's
      `ENV` is backed by a `Hash`-flavored object rather than MRI's
      anonymous-object singleton, so it never trips the singleton-detection
      check at all. **CANTFIX**: a JRuby object-representation difference,
      and not a realistic thing to special-case for one object.
    * `test_ciphers`, `test_property`, `test_verification`
      (`test/soap/ssl/test_ssl.rb`) -- fail with
      `TypeError: failed to coerce java.lang.String to [Ljava.lang.String;`.
      Confirmed via backtrace inspection that this is entirely inside the
      `httpclient` gem's own JRuby-specific SSL socket bridge
      (`httpclient/jruby_ssl_socket.rb`), not soap4r-ng's code.
      **CANTFIX** (upstream, in a dependency).
    * `test_nestedexception` (both `SOAP::TestMapping` and
      `SOAP::TestNestedException`) -- JRuby's backtrace formatting differs
      from every MRI format the test already branches on by Ruby version.
      **CANTFIX**: nothing to version-branch against, since it's the Ruby
      engine that differs, not the Ruby version.

  A handful of other JRuby-only failures (`test_calc`, `test_calc2`,
  `test_calc_cgi`, `test_authfailure` x2, `test_mu`) turned out to be a real,
  fixable bug rather than a JRuby limitation: `SOAP::Mapping.fault2exception`
  (`lib/soap/mapping/mapping.rb`) assumed a reconstructed fault exception
  always has a non-nil `.backtrace`, which doesn't hold on JRuby for a
  programmatically-constructed (never actually `raise`d-and-caught)
  exception object. Fixed with a nil-guard; confirmed clean on both JRuby and
  MRI afterward.
* **`SOAP4R_HTTP_CLIENTS=faraday SOAP4R_FARADAY_ADAPTER=patron`** -- not run
  in CI at all (see "HTTP Client Backends" above), but documented here since
  it's a real, reproducible issue for anyone who does reach for it: the
  CGI-based tests (`test_calc_cgi`, `test_authheader_cgi`) fail with
  `Patron::Aborted: Callback aborted`. Root-caused down to `patron` itself,
  not this project's code: reproduced with a bare `Patron::Session#post`
  against the exact same WEBrick CGI-subprocess server, with no soap4r-ng or
  Faraday code in the path at all. A raw TCP-level dump of that server's
  response ruled out the obvious suspect (a missing `Content-Length` forcing
  connection-close framing) -- the response has one. Most likely explanation
  left unconfirmed without reading patron's C extension directly: patron
  implements its own request timeouts via a libcurl progress callback, and
  the CGI handler's per-request subprocess spawn (a few hundred ms before
  the first byte, unlike every other test's in-process handler) is the one
  thing that reliably distinguishes the failing requests from every passing
  one, including under `curb` (also libcurl-based) and both adapters CI
  actually runs. **CANTFIX** without a patron-side fix we don't control.

#### How to Use
* [NaHi's Original documentation](https://web.archive.org/web/20101212040735/http://dev.ctor.org/soap4r/wiki/) -- the authoritative reference material is still available through the Wayback Machine, thankfully!
* [Soap4R-NG Website](http://rubyjedi.github.io/soap4r/) -- My own attempt at incorporating and modernizing the above into GitHub Pages -- still a work in progress at this time.

#### How to Get a Speed Boost : Use Nokogiri or Ox, not REXML
Be sure to have Nokogiri or Ox available in your Gemset. Soap4R-ng will find and use what's available (Ox has highest precedence, then Nokogiri, then LibXML, then Oga, falling back to REXML as the last resort if needed).

I personally recommend **Nokogiri** as the best performing, most flexible parser at this time, as it handles "special characters" like HTML ampersand-escaped characters internally. Ox doesn't handle such an extensive set of special-characters natively, so to get things up to par, I added **htmlentities** support if it's available when using the Ox parser. Using **htmlentities** with **Ox** in this manner adds a bit of a performance penalty, however.

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
