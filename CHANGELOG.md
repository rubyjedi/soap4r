# Changelog

Detailed rationale and investigation notes for non-obvious dependency and
compatibility decisions. Kept separate from README.md/code comments so
those stay skimmable; this is the place to look for the "why" in full.

## Unreleased

### WS-Security: two real Ruby 1.8.7 bugs found and fixed

The WS-Security work above was verified end-to-end against a minimum
viable sample of the full supported Ruby range -- 1.8.7 (oldest), 3.4.10,
and 4.0.5 (newest) -- both via `rake test:deep` (all applicable XML
parsers: oxparser/nokogiriparser/libxmlparser/rexmlparser on 1.8.7, plus
ogaparser on 3.4.10/4.0.5) and via a fresh e2e script exercising real
WS-Security operations against all four test-server engines
(bernardo-mg, rub-nds-cxf, rub-nds-metro, rub-nds-axis2), across every
applicable parser on each Ruby version. This surfaced two real,
previously-unknown Ruby 1.8.7 bugs in `wssecurity.rb` -- both pre-existing
(neither is in code this session's SOAP 1.2 fix touched), and both fixed:

1. **`decrypt_xml_enc_content`'s de-padding used `padded.bytes.last`.**
   `String#bytes` without a block returns an Array on Ruby >= 1.9 but an
   Enumerator on 1.8.7, and 1.8.7's Enumerator backport has no `#last` --
   `NoMethodError: undefined method 'last' for #<Enumerable::Enumerator>`
   on every single decryption (any endpoint using `EncryptionFilter`,
   standalone or combined). Fixed with `padded.unpack('C*').last` instead
   -- `String#unpack('C*')` has meant "Array of byte values" consistently
   across every Ruby version this library supports.

2. **A real old-libxml2 fragment-parsing bug, not a soap4r logic bug.**
   After the fix above, CXF's `/encsign` (combined Encrypt+Sign) still
   failed on 1.8.7 specifically with `VerificationError: digest mismatch
   for signed reference`, while the identical combined-sign-encrypt flow
   passed cleanly against bernardo-mg, rub-nds-metro, and rub-nds-axis2 on
   the same Ruby version -- ruling out a general 1.8.7 problem and
   pointing at something CXF-response-shape-specific instead. Captured
   the actual decrypted plaintext and its post-fragment-reparse
   canonical form side by side: the plaintext's unprefixed `<return>`
   child (correctly namespace-less -- only a *prefixed* `xmlns:ns2` was
   in scope, no default `xmlns=`) canonicalized as `<ns2:return>` after
   `Nokogiri::XML.fragment(plaintext)` -- Nokogiri 1.5.11 (the version
   this project pins for Ruby 1.8.7, bundling a circa-2013 libxml2)
   incorrectly makes an unprefixed element inherit a same-scope
   *prefixed* sibling namespace declaration when reparsing a standalone
   fragment with no surrounding document context. Modern Nokogiri/libxml2
   (confirmed on 3.4.10/4.0.5) resolves the same fragment correctly.
   Fixed without forking any version-specific logic: a new
   `WSSE.fragment_with_scoped_default_ns` helper makes the "no default
   namespace" already implied by the fragment *explicit*
   (`xmlns=""` injected onto the root element, only if one isn't already
   present) before parsing -- a no-op for a correctly-behaving parser,
   since it doesn't change what the fragment's own namespace resolution
   already was, but forces the buggy old parser to resolve it correctly
   too. Applied at both `Nokogiri::XML.fragment(plaintext)` call sites
   (`EncryptionFilter`'s real decrypt, `SignatureFilter`'s
   pre-encryption-plaintext verification fallback) since either could hit
   the same bug given the right response shape.

**Full result after both fixes**: `rake test:deep` is clean (374 tests,
2712 assertions, 0 failures/errors) on 3.4.10 and 4.0.5 across all 5
parsers; 1.8.7 matches its own documented "Known Test Suite Exceptions"
baseline exactly (CGI/WEBrick-subprocess flakiness, `Kernel#singleton_class`
not existing until 1.9.2, occasional Time-arithmetic flakiness in a WSDL
date-marshaling test -- none WS-Security-related) across all 4 applicable
parsers, no new failures. The WS-Security e2e script passes 13/13 checks
against all four test-server engines, on every applicable parser, on all
three Ruby versions (1.8.7, 3.4.10, 4.0.5) -- Signature-only,
Timestamp-only, Encryption-only, combined Encrypt+Sign (both SOAP 1.1 and
1.2), and UsernameToken all confirmed working end to end regardless of
Ruby version or XML parser backend.

### WS-Security: SOAP 1.2 support (`security_header_for`, `EncryptionFilter`)

SOAP 1.2 support itself (`SOAP::SOAPVersion`, `lib/soap/soapversion.rb`) has
been in master since `f28df683`, and every version-sensitive piece of the
core library (`SOAPHeader`/`SOAPBody`/`SOAPEnvelope`, `Proxy#route`) already
threads a driver's configured `soap_version` through correctly. WS-Security
never got the same treatment: `wssecurity.rb` built its own header and body
elements without passing that value through, so they silently fell back to
their constructors' `SOAPVersion1_1` default regardless of what the driver
was actually configured for. Three call sites needed fixing, all the same
root cause:

1. `WSSE.security_header_for` built `SOAP::SOAPHeader.new` with no
   arguments -- always 1.1-shaped. Now takes the filter's `opt` hash
   (already available in every `on_outbound(envelope, opt)` -- `opt`
   is set by `Proxy#create_encoding_opt` on every request, no new
   plumbing needed) and passes `opt[:soap_version]` through.
2. `EncryptionFilter#on_outbound` set the Security header's
   `mustUnderstand` attribute using the hardcoded, SOAP-1.1-only
   `AttrMustUnderstandName` constant (`lib/soap/soap.rb`) instead of the
   version-aware `mustunderstand_attr_name` that `SOAPHeaderItem#encode`
   already uses elsewhere in the codebase.
3. `EncryptionFilter#on_outbound` replaced the message Body with a bare
   `SOAP::SOAPBody.new` (again 1.1-shaped by default) when swapping the
   plaintext payload for `xenc:EncryptedData`.

Confirmed via `rake test:deep` (374 tests, 2712 assertions, same
pre-existing unrelated 1-failure baseline -- no regressions) and end to
end against a real server: of the four WS-Security test engines in
`soap4r-ws-security-testbed`, only `rub-nds-axis2` actually publishes a
SOAP 1.2 binding/port (`axis2-encsignHttpSoap12Endpoint` -- Axis2
auto-generates SOAP 1.1, SOAP 1.2, and plain-HTTP ports for every deployed
service; bernardo-mg/Spring-WS, rub-nds-cxf, and rub-nds-metro's WSDLs
exposed SOAP 1.1 only). Ran the same combined Encrypt-then-Sign chain this
session already fixed for SOAP 1.1 against Axis2's SOAP 1.2 port:

- Before the fix: crashed client-side before any bytes hit the wire --
  `XSD::NS::FormatError: namespace: http://schemas.xmlsoap.org/soap/envelope/
  not defined yet` -- because the hardcoded 1.1 constructs collided with
  the SOAP 1.2 envelope's own namespace table during serialization. Not
  just a cosmetic mismatch; the request couldn't even be built.
- After the fix: succeeds end to end (`getServerTime` round-trips
  correctly), and the wire dump confirms the Security header's
  `mustUnderstand` attribute correctly uses the SOAP 1.2 envelope
  namespace (`http://www.w3.org/2003/05/soap-envelope`) with value `"1"`,
  matching the driver's configured `soap_version`.

(A signature-only call against the same Axis2 SOAP 1.2 port failed with
`400: Expected encrypted part missing` -- that's the endpoint's own
WS-SecurityPolicy requiring both encryption and signing, not a soap4r
issue; the `/encsign` name says as much.)

Follow-up: the four test engines were then extended (see
soap4r-ws-security-testbed's own CHANGELOG.md, "rub-nds-cxf/rub-nds-axis2:
new SOAP 1.2 and UsernameToken endpoints") specifically to close the gap
above, adding SOAP 1.2 ports for Signature-only and Timestamp-only
(`rub-nds-cxf`'s new `/sign12`, `/ts12`) and for UsernameToken
(`rub-nds-axis2`'s new `axis2-ut`, `axis2-ut-digest`), none of which
existed anywhere in this testbed before.

- **`TimestampFilter`/`SignatureFilter` under SOAP 1.2**: fully verified
  end-to-end against `rub-nds-cxf`, passing identically to their existing
  SOAP 1.1 counterparts, wire dumps confirming the correct SOAP 1.2
  envelope namespace throughout.
- **`UsernameTokenFilter` under SOAP 1.2**: soap4r's own wire format is
  confirmed correct in both modes (PasswordText accepted structurally by
  `rub-nds-axis2`; PasswordDigest's Nonce+Created+digest bytes
  independently confirmed correct by cross-checking the identical soap4r
  code against `bernardo-mg`'s separate WSS4J stack, which accepts it
  cleanly). Full accept/reject round-tripping against Rampart specifically
  is blocked by what looks like a genuine Rampart 1.8.0/WSS4J 3.0.3
  version-mismatch bug in that engine (see the testbed CHANGELOG for the
  detailed trace) -- a testbed/server limitation, not a soap4r defect.

### WS-Security: combined sign+encrypt fix (`/encsign`, `/enctssign`)

`SignatureFilter` + `EncryptionFilter` chained together (WS-Security
"Encrypt then Sign") previously failed against real WSS4J servers
(CXF, Axis2/Rampart) with a generic `"The signature or decryption was
invalid"` / `SignatureProcessor.verifyXMLSignature` error. An earlier
investigation had concluded this was a longstanding WSS4J library bug
spanning versions 1.6.4-2.1.x -- **wrong**, and worth recording why, since
it's an easy trap to fall back into.

The user correctly pushed back on that conclusion: the RUB-NDS test
engines expose `/encsign`/`/enctssign` as real, expected-to-work
pentest-target endpoints (confirmed by RUB-NDS's own SoapUI project file,
which has a working "Enc+Sign" profile targeting exactly this endpoint) --
they wouldn't have been left broken and unnoticed. That challenge is what
led to actually building a real CXF/WSS4J Java client (scratch, not
committed) against the live `rub-nds-cxf` server and diffing its genuine
raw wire bytes against soap4r's own, which surfaced two real soap4r bugs
instead:

1. **Wire element order is the reverse of crypto work order.** A WSS4J
   sender inserts each action's header contribution at the *front* of
   `wsse:Security` as that action completes -- so for "Encrypt then Sign"
   the wire order is Signature's own BST+Signature *first*, then
   EncryptedKey's BST+ReferenceList *second*, even though the encrypt
   work happened first. soap4r was just appending both filters' output in
   filterchain-execution order (EncryptedKey first), so a receiving WSS4J
   server would decrypt -- mutating the Body from ciphertext back to
   plaintext *in place* -- before it ever verified the Signature's
   digest, causing a mismatch even though soap4r's own digest was
   computed correctly all along. Fixed with a new `SOAP::SOAPElement
   #unshift` (`lib/soap/baseData.rb`, mirrors `#add`) that
   `SignatureFilter#add_signature_to_security` uses to prepend its BST +
   Signature ahead of whatever `EncryptionFilter` already added --
   correct regardless of which filter actually runs first.

   A first attempt to diagnose this by eye was misled by
   `LoggingOutInterceptor#setPrettyLogging(true)` on the Java reference
   client: it reformats the *logged* text through a pretty-printer, which
   is not the actual wire bytes (C14N digests are whitespace-sensitive).
   That misread the real order as "Signature first" being an artifact
   rather than the truth. Caught by replaying the pretty-printed capture
   via raw `curl` -- it failed even though the original call had
   succeeded, proving the log wasn't the real bytes. Removing
   `setPrettyLogging(true)` gave the true raw order.

2. **A single endpoint can use opposite sign/encrypt order for requests
   vs. responses.** Confirmed directly in rub-nds-cxf's own
   `cxf-servlet.xml`: the same `/encsign` endpoint's inbound
   (request-validating) interceptor is configured `action="Encrypt
   Signature"`, while its outbound (response-building) interceptor is
   configured `action="Signature Encrypt"` -- the opposite order. So the
   server signs its own responses *before* encrypting them, meaning the
   signed digest covers plaintext that no longer exists by the time the
   client sees ciphertext. Wire order alone can't disambiguate this
   either, since (per finding 1) it's always the reverse of work order
   regardless of what that order was.

   Fixed by having `SignatureFilter#on_inbound` retry against a
   temporary, non-mutating decrypt (`digest_after_temp_decrypt`, using a
   `doc.dup` scratch copy) whenever the direct digest check fails,
   instead of assuming one fixed order. The scratch copy matters:
   `EncryptionFilter`'s own `on_inbound`, still to run later in the same
   filterchain, needs to see the untouched, still-encrypted document to
   do its own real, permanent decrypt and header cleanup. The AES/RSA
   decrypt logic itself was factored out of `EncryptionFilter#on_inbound`
   into shared `WSSE.resolve_encrypted_key`/`WSSE.decrypt_xml_enc_content`
   module functions so the tentative and real decrypts don't duplicate
   crypto code.

An earlier, now-reverted attempt at fixing finding 1 had instead made
`SignatureFilter` reconstruct and sign the *original pre-encryption*
plaintext -- based on the same pretty-printing misdiagnosis above. That
was removed once the corrected raw capture showed a real WSS4J client
signs the post-encryption ciphertext directly, no reconstruction needed.

**Verified against all three RUB-NDS WSS4J-family test engines**
(`soap4r-ws-security-testbed/rub-nds-{cxf,metro,axis2}`):
- **rub-nds-cxf** (WSS4J 3.1.7): `/encsign` and `/enctssign` both now pass
  end-to-end (request accepted, response verified).
- **rub-nds-axis2** (Rampart/WSS4J 1.6.4 -- a materially different, older
  version from CXF's): `/encsign` now passes too. This is the strongest
  evidence the original "WSS4J bug" theory was wrong -- the same fix
  resolves it across two independent WSS4J versions, which a real library
  bug specific to one version wouldn't do.
- **rub-nds-metro**: at the time of this fix, still failed with a
  *separate*, unrelated issue (`"Validation of self signed certificate
  failed"` -- Metro's own PKIX trust validation of the test server's
  self-signed cert, not a wire-format problem). Not addressed here --
  fixed later, testbed-side only (no soap4r code changes needed), see
  `soap4r-ws-security-testbed/CHANGELOG.md` ("rub-nds-metro: self-signed
  cert validation"). `/encsign` passes against all three RUB-NDS engines
  as of that fix.

Full `rake test:deep` run clean afterward (374 tests, 2712 assertions, 1
pre-existing unrelated failure -- a `NoMethodError#message` encoding flake
in an exception-marshaling test, untouched by this work).

### Faraday gated to Ruby >= 2.6

`gem 'faraday'` was previously unconstrained, which resolved *some* old
release for every Ruby down to 1.9.3 -- but that old-Faraday territory
turned out to be broken, not just untested:

- Below Faraday 1.10 (resolved as far up as Ruby 2.3.8), net_http support
  is bundled directly into the main `faraday` gem with no separate
  `faraday-net_http` package. `lib/soap/faradayClient.rb`'s
  `require "faraday/#{adapter}"` convention assumes the modern
  split-into-per-adapter-gems architecture, so it can't load any adapter
  at all there -- an architecture mismatch, not a version-selection bug.
- Ruby 2.4.10/2.5.9 resolve Faraday 1.10.6, which does carry a real
  `faraday-net_http` dependency and gets further, but hits a distinct bug:
  `TypeError: wrong argument (String)! (Expected kind of
  OpenSSL::X509::Certificate)` deep inside `Net::HTTP#connect`, from
  `faradayClient.rb` passing a raw file-path string where curb's own
  client already correctly converts to a parsed certificate object.

Decision: Faraday is a modern-transport enhancement, not a legacy
capability worth carrying forward two Ruby versions for. Gated to
`>= 2.6` outright, matching `faraday-typhoeus`'s own real floor
(confirmed: its oldest RubyGems release needs Ruby >= 2.5's `logger`, and
the next release requires Ruby >= 2.6 directly). `faraday-patron` bumped
to the same floor since an adapter gem is inert without its host.

`curb` has the equivalent floor for an unrelated reason: its C extension
references `CURL_SSLVERSION_MAX_*` constants absent before libcurl 7.54.0.
The official `ruby:2.2.10`/`ruby:2.3.8` Docker Hub images' system
`libcurl-dev` predates that (confirmed hard compile failure, not a
graceful skip); `ruby:2.4.10`'s image is new enough.

CI had a latent bug matching both of these: `bundle config set with "..."`
is Bundler 2.x-only syntax. Bundler 1.17.3 (what every Ruby < 3.2 falls
back to) has no `set` verb and silently creates a bogus config key
literally named `"set"` -- meaning curb/faraday were never actually
exercised in CI below Ruby 3.2. Fixed with the `BUNDLE_WITH="group1:group2"`
env var instead (confirmed identical behavior on both Bundler
generations), exported (not just prefixed on the `bundle install` line)
since `bundle exec`'s own `Bundler.setup` re-checks group inclusion
independently for that invocation too. Both `ci.yml` steps also needed
explicit skip-and-exit-0 logic below their respective floors --
previously a Ruby version below the floor would hard-fail the whole job
(`RuntimeError: HTTP client backend not found`) rather than skip cleanly.

### Ox pin split three ways (dropping htmlentities where possible)

The Gemfile pins Ox differently depending on Ruby version because
compatibility and entity-decoding behavior don't move together, or even
monotonically, across releases -- confirmed by installing every Ox
release from 2.4.5 through 2.14.28 across Ruby 1.8.7, 1.9.3, 2.0.0, and
2.1.10 and testing both (a) whether it loads and (b) whether it decodes
named HTML entities (`&hellip;`, `&mdash;`) natively via
`:convert_special => true`:

- Entity decoding never improves anywhere in 2.4.5-2.8.0 (identical,
  undecoded output throughout every version tested). It first improves at
  **2.13.4** (2020-09-12), which decodes the same named-entity set
  htmlentities does, byte-identical on direct comparison.
- **2.14.7** is the first release to call `rb_utf8_str_new`, a symbol not
  exported by Ruby's shared lib before 2.2 -- `undefined symbol:
  rb_utf8_str_new` at native-ext load time on Ruby 2.0.0/2.1.10. Oddly,
  this does *not* reproduce on Ruby 1.9.3 even with the same Ox version --
  Ox's extconf must feature-detect the symbol differently depending on
  which Ruby's headers are present at compile time, so the boundary isn't
  a simple "older Ruby is safer" gradient; each version needs testing
  directly rather than assumed from a neighbor.
- **2.14.6** is therefore the newest release confirmed to work, with
  correct entity decoding, on 1.9.3, 2.0.0, *and* 2.1.10 uniformly. Pinned
  exactly (`= 2.14.6`), since the very next patch release breaks it.
- **Ruby 1.8.7** can't use 2.14.6 at all: its `extconf.rb` fails outright
  with `undefined method 'slice!' for nil:NilClass`, an mkmf/extconf
  incompatibility with 1.8.7's build tooling, unrelated to the
  `rb_utf8_str_new` issue above. Falls back to the older `= 2.4.5` pin,
  which does compile and load there but only decodes the basic 5 XML
  entities -- htmlentities is still required, and only there.
  - Pinned exactly (`= 2.4.5`, not `~>`): later 2.4.x patches (confirmed
    with 2.4.13) hit a *second*, different unresolvable-symbol crash
    (`RSTRUCT_GET`) on Ruby 2.0.0/2.1.10 -- though notably *not* on
    1.8.7/1.9.3, the same non-monotonic pattern as the 2.14.x boundary
    above. Moot now that 1.8.7 is the only Ruby left in this branch, but a
    floating patch-level constraint would silently regress this the
    moment that changes.
  - `htmlentities 4.3.1` pinned exactly there too: 4.3.3+ hard-fails on
    1.8.7 with `NameError: uninitialized constant
    HTMLEntities::Decoder::Encoding` (references Ruby's `Encoding` class,
    introduced in 1.9, absent on 1.8.7).

A CRLF regression was found and fixed along the way, incidental to this
investigation: `lib/xsd/xmlparser/oxparser.rb`'s no-decoder branch used
`:skip => :skip_return`, which discards `\r` -- unrelated to entity
decoding, but broke CRLF round-tripping (`test_string_crlf`) for anyone
running without htmlentities installed. Changed to `:skip_none`
unconditionally.

Regression matrix re-run after these changes: 1.9.3, 2.0.0, and 2.1.10 all
green; 1.8.7 shows only its pre-existing, already-documented exceptions
(see "Known Test Suite Exceptions" below) -- no new failures introduced.
**This re-run did not include Ruby >= 2.2** (its `gem 'ox'` branch wasn't
touched by this change, so it seemed out of scope at the time) -- see the
correction directly below, found days later while reordering these same
Gemfile branches for an unrelated reason.

### Correction: htmlentities still required on Ruby 2.2.x - 2.6.x

The "htmlentities is dead weight above 1.9.3" conclusion above was wrong
for part of that range. `gem 'ox'` unconstrained (the `>= 2.2` branch)
resolves whatever the newest Ox release is for the running Ruby -- and Ox
added a hard `Ruby >= 2.7.0` requirement to its own gemspec starting at
2.14.15. That means Ruby 2.2.x-2.6.x are stuck resolving **2.14.14** (the
last release before that floor), while Ruby >= 2.7 gets 2.14.15+.

2.14.14 segfaults inside `Ox.sax_parse`'s `:convert_special => true` path
on complex documents -- confirmed via a real crash in `test_mapping.rb`
(`[BUG] Segmentation fault` at `oxparser.rb:33`), reproduced identically on
Ruby 2.2.10, 2.3.8, 2.4.10, and 2.6.10, while a bare, simple XML string
through the same code path does *not* crash (so it's data/complexity
dependent, not a trivial always-fails bug -- a quick smoke test wouldn't
have caught it). Ruby 2.7.8 (resolving Ox 2.14.28) and Ruby 3.0.7/3.4.10/
4.0.5 all run the same test cleanly.

`htmlentities` avoids the bug entirely by design, not by luck:
`oxparser.rb` only passes `:convert_special => true` when no decoder is
present; with htmlentities installed, Ox is called without that option and
never enters the buggy path. So for Ruby 2.2.x-2.6.x, htmlentities is a
required workaround, not an optional speed boost -- `gem 'htmlentities'`
was restored there (Gemfile), unconstrained Ox unconstrained-and-safe only
from Ruby >= 2.7.

This was only caught because a later, unrelated task (reordering the
Gemfile's version-gate branches newest-first) prompted a fresh full-matrix
re-run that happened to include Ruby 2.2.10 for the first time since the
original htmlentities change. The lesson: a version-gate boundary that
touches one branch's *dependency count* (adding/removing a gem) can change
behavior in a sibling branch that looks untouched, if both branches share
downstream code (`oxparser.rb`) that behaves differently based on which
gems happen to be present -- worth re-running the full matrix after any
Gemfile change that touches a shared code path, not just the Ruby
versions whose own branch changed.

### CI: Docker-per-version architecture, not ruby/setup-ruby

`ci.yml`'s `test` job runs each Ruby version via a plain `docker run` of
the exact same official `ruby:X.Y.Z` image used for local validation,
rather than a `ruby/setup-ruby`-based matrix on the GitHub-hosted runner
VM directly, and rather than the job-level `container:` key.

- The earlier `ruby/setup-ruby` approach kept drifting from local
  validation in ways that cost real debugging time: `ubuntu-latest`
  rolling forward under a pinned Ruby version, `ruby-builder` not always
  publishing a binary for every Ruby x Ubuntu combination, and Ubuntu
  22.04's ICU-enabled system libxml2 colliding with `libxml-ruby`'s C
  extension in a way that never reproduced locally against Debian. Running
  the identical container makes "works locally" and "works in CI" the same
  claim by construction.
- `container:` was tried and rejected: GitHub Actions injects its own
  Node.js runtime into container jobs to run JS-based steps like
  `actions/checkout`, and most of these official `ruby` images are old
  enough (Debian jessie/stretch-era glibc) that the injected Node 24
  binary can't execute (`version 'GLIBC_2.27' not found`), failing
  checkout before a single test runs. Confirmed empirically: every job up
  through Ruby 2.7 failed this way. Checkout instead runs on the runner VM
  as normal, and a plain `docker run` does the actual `bundle install`/test
  run inside the target image.
- Exact patch-level tags (e.g. `2.4.10`, not `2.4`) are pinned to match
  precisely what was locally validated, even though these are all
  EOL/frozen lines where the floating tag would resolve identically.

### CI: BUNDLE_WITH bug (curb/faraday silently never tested below Ruby 3.2)

`bundle config set with "http_curb"` is Bundler 2.x-only syntax. Every
Ruby below 3.2 in this matrix falls back to Bundler 1.17.3 (the last
release installable there), whose `config` CLI has no `set` verb at all --
under 1.17.3 that command silently creates a bogus config key literally
named `"set"` (value `"with http_curb"`) instead of configuring the `with`
group list. Confirmed empirically: `bundle config` afterward showed the
bogus key, and `SOAP4R_HTTP_CLIENTS=curb` then failed with "HTTP client
backend not found" against a gem that was never installed. Meaning: every
curb/faraday CI step below Ruby 3.2 had been silently testing nothing.

Fixed with the `BUNDLE_WITH="group1:group2"` env var instead -- the same
underlying mechanism a persisted `bundle config` writes to, confirmed
working identically on both Bundler generations. It must be `export`ed
(not just prefixed on the `bundle install` line): `bundle install` alone
happily installs an optional group's gems to disk even without
`BUNDLE_WITH` set for a later command, but `bundle exec`'s own
`Bundler.setup` excludes `:optional => true` groups from the load path by
default unless told to include them for that invocation too -- confirmed
empirically that a `bundle exec` immediately after a successful,
curb-installing `bundle install` still raised `LoadError` on `require
'curb'` without `BUNDLE_WITH` set again.

Both the curb and faraday CI steps also needed explicit skip-and-exit-0
logic below their respective Gemfile floors (Ruby >= 2.4 / >= 2.6): without
it, a matrix entry below the floor would hard-fail the whole job
(`RuntimeError: HTTP client backend not found`) under `set -e` with no
`continue-on-error` at that granularity, rather than skip cleanly.

### CI: port 17171 clearing between parser runs

All parsers/backends run as separate `rake test:deep` invocations
sequentially in one long-lived container, sharing a hardcoded port (17171)
used throughout the test suite. Confirmed via CI logs (Ruby 2.7.8, run
28854082576) that something can stay bound to that port across a process
boundary for minutes, well past the widened retry budget in
`test/testutil.rb` (60 tries/1s). Never reproduced locally, and not fully
root-caused (suspected a WEBrick/CGI-handler subprocess not fully
released) -- `fuser -k -n tcp 17171` runs before every iteration
regardless of cause rather than keep guessing at timing.

Relatedly, `set -e` must not wrap the parser loop itself (only the setup
steps before it): `rake test:deep` exits non-zero on any test failure, and
several Ruby versions have exactly one guaranteed failure on every parser
(see "Known Test Suite Exceptions" below) -- under `set -e` that killed the
script after the first parser alone, silently skipping the rest without
anyone noticing (confirmed: CI logs showed only one parser ever ran for
those versions). Failures are tracked in a variable and the loop always
runs to completion instead.

### CI: summary job's GFM table-adjacency gotcha

The `summary` job uses `core.summary.addTable()` (an actual HTML
`<table>`) rather than hand-rolled markdown pipe syntax, because a
markdown table placed immediately after `addHeading()`'s `<h2>` HTML with
no blank line in between doesn't get parsed as a table at all (GitHub
Flavored Markdown requires a fresh block boundary before table syntax) --
confirmed on a live run, where the whole thing rendered as one
literal-pipe-character paragraph instead of a table.

### CI: legacy Ruby build strategy (1.9.3, 2.0.0, 1.8.7)

1.9.3 and 2.0.0 have official Docker Hub images, but every tag in both
lines was published in the legacy Docker manifest v1 schema and is no
longer pullable at all (confirmed empirically: `not implemented: media
type ... manifest.v1+prettyjws ... no longer supported since containerd
v2.1`, against every tag tried). GitHub-hosted runners hit the same wall.
Built from source instead via rbenv/ruby-build on Debian bullseye
(`Dockerfile.legacy`) -- confirmed clean across all 5 parsers for both
versions, including libxmlparser (bullseye's libxml2-dev doesn't have
Ubuntu 22.04's ICU/`bool`-collision problem) and ogaparser (oga's ruby-ll
dependency installs and works fine on both, unlike 1.8.7 below).

1.8.7 has no official Docker Hub image at all (the `ruby` library starts
at 1.9) and no ruby-build definition with OpenSSL handling, so
rbenv/ruby-build can't get it for free. `Dockerfile.legacy187` builds it
from source against a vendored OpenSSL 1.0.2u instead (confirmed working:
`openssl.so` builds, `OpenSSL::SSL::SSLContext.new` instantiates
correctly). `oga` is intentionally excluded from its parser loop: its
`ruby-ll` dependency genuinely needs Ruby >= 2.1 on this version (unlike
1.9.3 above), so it's correctly never installed there.

### HTTP client backend rollout (curb/faraday, wiredump parity, TLS trust)

`http-access2` (httpclient's old name, same author) is no longer published
on RubyGems.org at all; retired from the backend cascade for the same
reason. See git history for the adapter that used to sit here.

Before `SOAP4R_HTTP_CLIENTS` existed as an independently selectable env
var, nothing in the test suite could ever actually reach the `net_http`
fallback -- this project's Gemfile always installs `httpclient`, so the
cascade never had a reason to fall through to it. Making backends
independently selectable surfaced (and fixed) a real bug in the process:
`SOAP::NetHttpClient`'s wiredump output duplicated request/response bodies
and was missing the raw request-line/header block entirely, corrupting
any test or tool parsing `wiredump_dev` output.

Several tests (WSDL-driven codegen round-trips, request-envelope
assertions, ASP.NET-handler interop) used to be gated to `httpclient` only
because they parsed `wiredump_dev` output assuming its specific block
layout. That layout turned out to already be backend-neutral by design
once `NetHttpClient`/`CurbClient`/`FaradayClient` were all built to mirror
it -- confirmed by simply removing the gates and running the suite
unmodified under every backend. The duplicated parsing logic across those
test files is now consolidated into
`TestUtil.parse_wiredump_request_body`/`parse_wiredump_response_body`
(`test/testutil.rb`).

`test/soap/ssl/test_ssl.rb` runs its SSL config-loading coverage against
every SSL-capable backend now, not just httpclient: `test_ca_verification`
and `test_ciphers` (rewritten to expect each backend's own real exception
class -- `OpenSSL::SSL::SSLError` for httpclient, `Curl::Err::CurlError`
for curb, `Faraday::Error` for Faraday; confirmed empirically, since
test-unit's `assert_raise` wants an exact class match).
`test_options`/`test_verification`/`test_property` stay httpclient-only:
they're built around `ssl_config.verify_callback`, and neither
libcurl-based backend (curb, or Faraday on typhoeus/patron) exposes a
per-certificate Ruby callback hook at all -- confirmed against both
libraries' public APIs. Faraday's own adapter list is deliberately not
swept exhaustively in CI -- `lib/soap/faradayClient.rb` is what's under
test, and sweeping every adapter Faraday supports would mostly re-test
Faraday's own correctness. `:typhoeus` was chosen as the one CI adapter
because it's also the one people actually reach for in practice (28
reverse dependencies on RubyGems vs. `faraday-patron`'s 3, per [Ruby
Toolbox](https://www.ruby-toolbox.com/projects/faraday-typhoeus)); Faraday's
own `faraday-typhoeus` adapter was confirmed to silently drop the
`ciphers` option (never forwards it to `ethon`'s `ssl_cipher_list`) -- a
real gap in that third-party adapter, not this bridge.

`httpclient`'s `SSLConfig` doesn't trust the system CA bundle unless told
to -- left unconfigured, it lazily falls back to its own gem-vendored
`cacert.pem` snapshot, which can go stale relative to a real server's
certificate chain as CAs rotate intermediates (confirmed directly: a real
Let's Encrypt-signed endpoint failed verification against an older bundled
snapshot while verifying fine against the host's own CA bundle).
`lib/soap/httpbackend/httpclient.rb` now calls `set_default_paths` on
every connection's `ssl_config` by default, deferring to whatever CA store
OpenSSL was built to trust on the platform, layered before any
`ssl_config.ca_file`/`ca_path`/`cert_store` set explicitly. `NetHttpClient`
was never affected -- it has no SSL config surface of its own and defers
to stdlib `Net::HTTP`/OpenSSL defaults directly.

## Known Test Suite Exceptions (full detail)

Short summary lives in README.md; full root-cause narrative here.

- **Ruby 1.8.7**:
  - 3 errors (`test_time`, `test_time_ivar`, `test_time_subclass` in
    `marshaltestlib.rb`): `Kernel#singleton_class` doesn't exist until Ruby
    1.9.2. CANTFIX -- the method is absent on that Ruby, full stop.
  - CGI-based tests (`test_calc_cgi`, `test_authheader_cgi`) fail with
    `SOAP::ResponseFormatError: ... Internal Server Error`. Root-caused
    partway: WEBrick's `CGIHandler` wipes the spawned CGI subprocess's
    entire environment before exec'ing it, so `logger-application` and
    `webrick` need forwarding via a raw `-I` load-path flag (already fixed,
    in both test files). That forwarding alone wasn't enough on 1.8.7
    specifically: the spawned subprocess still hits `NameError: undefined
    local variable or method 'logger'` inside
    `lib/soap/rpc/cgistub.rb#run`, even though `Logger::Application#logger`
    is a real public method and a minimal reproduction of the same class
    hierarchy works fine in isolation. Not fully root-caused -- something
    specific to the real `CGIStub`/`AuthHeaderPortServer`/`CalcServer`
    class graph, only reproducible via the actual spawned-CGI-subprocess
    path. Narrow enough (2 of ~330 tests, both CGI smoke tests) that it
    wasn't worth further chasing.
  - Collateral damage from the CGI issue above: `test_nil_attribute` and
    `test_wsdl_with_map` (`test/wsdl/document/test_rpc.rb`) intermittently
    receive a garbage `dateTime` value (`XSD::ValueSpaceError`) when run as
    part of the full suite, but pass cleanly in isolation
    (`SCOPE=wsdl/document`). Confirmed state leaking from a still-lingering
    CGI subprocess/WEBrick thread earlier in the same run, not a genuine
    1.8.7 `Date`/`DateTime` bug -- `XSDDateTimeImpl#screen_data`'s `Time`
    branch produces a correct result in isolation. Not independently
    fixable -- same underlying CGI/WEBrick fragility, different test.
- **Ruby 2.4.10, 2.5.9, `SOAP4R_HTTP_CLIENTS=curb`**: `test_ca_verification`
  and `test_ciphers` (`test/soap/ssl/test_ssl.rb`) fail with
  `Curl::Err::SSLPeerCertificateError: ... unable to get issuer
  certificate`, even with a correct, complete CA chain supplied. CANTFIX --
  confirmed environment-specific: the official `ruby:2.4.10`/`ruby:2.5.9`
  images ship libcurl 7.64.0/OpenSSL 1.1.1d, while `ruby:2.6.10`+ ship
  libcurl 7.74.0/OpenSSL 1.1.1n; the same chain validates cleanly under the
  newer pair. httpclient/net_http (unaffected by libcurl version) pass
  this same test cleanly everywhere, confirming this is that older libcurl
  build, not this bridge's CA-file wiring.
- **Ruby 3.0.7, 3.1.7, 3.2.11**: 1 failure in `test_exception`
  (`marshaltestlib.rb`), which marshals an exception whose `.message`
  embeds a live `#inspect` dump of the entire running
  `Test::Unit::TestCase` (memory addresses, internal framework state and
  all). WONTFIX -- confirmed via minimal reproduction that soap4r-ng's own
  exception-marshaling round-trips correctly; the test itself compares
  volatile process/framework internals that render differently across this
  narrow patch-version range.
- **JRuby** (9.4.15.0 and 10.1.0.0, identical on both) -- 13 confirmed
  environment-specific items:
  - 7 `XSD::ValueSpaceError` tests (`test_SOAPInteger`, `test_XSDInteger`,
    etc.): JRuby's `Kernel#Integer()` silently stops validating trailing
    garbage once the digit count gets long enough, where MRI always raises
    `ArgumentError`. CANTFIX -- JRuby core-method behavior difference.
  - `test_singleton` (`marshaltestlib.rb`): expects marshaling `ENV` to
    raise `TypeError`. JRuby's `ENV` is backed by a `Hash`-flavored object
    rather than MRI's anonymous-object singleton, so it never trips the
    check. CANTFIX -- JRuby object-representation difference.
  - `test_ciphers`, `test_property`, `test_verification`
    (`test/soap/ssl/test_ssl.rb`): `TypeError: failed to coerce
    java.lang.String to [Ljava.lang.String;`, confirmed entirely inside
    `httpclient`'s own JRuby SSL socket bridge
    (`httpclient/jruby_ssl_socket.rb`). CANTFIX (upstream dependency).
  - `test_nestedexception` (both variants): JRuby's backtrace formatting
    differs from every MRI format already branched on. CANTFIX -- the
    engine differs, not the Ruby version.
  - A handful of other JRuby-only failures (`test_calc`, `test_calc2`,
    `test_calc_cgi`, `test_authfailure` x2, `test_mu`) turned out to be a
    real, fixable bug: `SOAP::Mapping.fault2exception` assumed a
    reconstructed fault exception always has a non-nil `.backtrace`, false
    on JRuby for a programmatically-constructed exception. Fixed with a
    nil-guard.
- **`SOAP4R_HTTP_CLIENTS=faraday SOAP4R_FARADAY_ADAPTER=patron`** -- not run
  in CI, but documented for anyone who reaches for it: CGI-based tests
  fail with `Patron::Aborted: Callback aborted`. Root-caused to `patron`
  itself: reproduced with a bare `Patron::Session#post` against the exact
  same WEBrick CGI-subprocess server, no soap4r-ng or Faraday code in the
  path. A raw TCP-level dump ruled out a missing `Content-Length`. Most
  likely explanation, unconfirmed without reading patron's C extension
  directly: patron implements its own request timeouts via a libcurl
  progress callback, and the CGI handler's per-request subprocess spawn (a
  few hundred ms before the first byte, unlike every other test's
  in-process handler) is the one thing distinguishing failing requests
  from passing ones, including under `curb` (also libcurl-based) and both
  adapters CI actually runs. CANTFIX without a patron-side fix.
