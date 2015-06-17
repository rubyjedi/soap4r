# soap4r-ng
## Soap4R (as maintained by RubyJedi)

**Maintainer's Note:** [2015-June-17] This fork of Soap4R has been tested to work with Ruby 1.8.7 thru 2.1.5. Support for Ruby 2.2 is coming soon. 

I have a vested interest in making this the ***fastest, most reliable*** successor to NaHi's original Soap4R library, and in maintaining and documenting it as best as can be reasonably expected. Soap4R has received a "bad reputation" amongst the Ruby Community for far too long. For me, NaHi's original code was brilliantly written, and the Unit Tests are quite comprehensive. 

In fact, I'd much prefer to forward-port Soap4R to work with newer Ruby Versions and keep a known-good thing going, versus take on the risk of porting already-written applications to use a different SOAP implementation. Along the way, I'm improving the performance with support for newer XML Parsers like **Ox** (screaming fast!) and **Nokogiri**; and I'm planning to add support for a faster HTTP Client such as **Curb**.

## Highlights of Soap4R-ng 
* Tested to be Compatible with Ruby 1.8 thru 2.1
* ***Fully Operational Unit Tests***. I'm **very** confident in this fork -- as long as NaHi's Unit Tests continue to pass, thiat is :-)
* ***faster XML Parsers*** : Support has been added for **Ox** (Fully Functional), **Nokogiri** (Fully Functional), and **Oga** (At this writing, Oga support is a work in progress)

### Why Name This "Soap4R-ng" ?
As felipec/soap4r (now soap2r) has pointed out upon renaming Soap2R, there is a LOT of competition to uniquely name the a "successor" to the original Soap4R. Soap2R came into being because "Soap5R" had already been claimed. :-)

## Speed Boost : Use Ox or Nokogiri, not REXML
Be sure to have Ox or Nokogiri available. Soap4R-ng will find and use what's available; falling back to REXML if needed.

More documentation coming soon.  For now, just know that you need to have Nokogiri or Ox included in your Gemfile so Soap4R-ng can find and use it. :-)

***More details to come soon!*** I'm hammering on getting Soap4R-ng working under Ruby 2.2 (As in "Regression Tests pass with Zero Errors or Warnings") before tackling any more enhancements like **Oga** or **Curb**.

