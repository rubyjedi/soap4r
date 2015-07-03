# soap4r-ng
[![Gem Version](https://badge.fury.io/rb/soap4r-ng.svg)](http://badge.fury.io/rb/soap4r-ng)
[![GitHub version](https://badge.fury.io/gh/rubyjedi%2Fsoap4r.svg)](http://badge.fury.io/gh/rubyjedi%2Fsoap4r)
[![Code Climate](https://codeclimate.com/github/rubyjedi/soap4r/badges/gpa.svg)](https://codeclimate.com/github/rubyjedi/soap4r)
[![Build Status](https://travis-ci.org/rubyjedi/soap4r.svg?branch=master)](https://travis-ci.org/rubyjedi/soap4r)

#### Soap4R (as maintained by RubyJedi)
* Unit Tested to work under MRI Ruby **1.8.7** thru **2.1.5**
* ***NEW CODE!  Added Support for newer, faster XML Parsers***
    * **[Ox](https://github.com/ohler55/ox)** (Fully Functional),
    * **[Nokogiri](https://github.com/sparklemotion/nokogiri)** (Fully Functional)
    * **[Oga](https://github.com/YorickPeterse/oga)** (Fully Functional)
* ***Fully Operational Unit Test Suite***. NaHi's Unit Tests are astonishingly thorough, and have been instrumental in discovering issues that each new Ruby version brings up. Thanks to those Unit Tests, I'm **very** confident in the code quality of this fork.
* ***Roadmap and Future Plans***
    * Much improved [GitHub-Pages Website](http://rubyjedi.github.io/soap4r/) for documentation and presentation purposes.
    * Support for newer, faster HTTP Clients like [Curb](https://github.com/taf2/curb)
    * Support for Ruby 2.2, JRuby, and (?) coming soon - depending on demand. (File an Issue, +1 to chime in and add support).
    * ***More to come soon***  - I'm hammering on getting Soap4R-ng working under Ruby 2.2 (As in "Regression Tests pass with Zero Errors or Warnings") before tackling the feature enhancements like **Oga** or **Curb**.

#### How to Install 
##### (Bundler Gemfile / GitHub Hosted)
```
## Performance Boosting Gems
gem 'ox'         # For faster XML Parsing, use Ox or Nokogiri. Ox has highest priority if available.
gem 'nokogiri'   # For faster XML Parsing. If neither Ox nor Nokogiri available, we'll fall back to REXML.
gem 'httpclient' # Absolutely necessary for soap4r-ng. Net::HTTP Fallback is quite broken, so don't let that happen.
#
gem 'soap4r-ng', :git=>'https://github.com/rubyjedi/soap4r.git', :branch=>"master"
```
##### Standard Ruby Gem
```
gem install soap4r-ng
```
#### How to Use
* [NaHi's Original documentation](https://web.archive.org/web/20101212040735/http://dev.ctor.org/soap4r/wiki/) -- the authoritative reference material is still available through the Wayback Machine, thankfully!
* [Soap4R-NG Website](http://rubyjedi.github.io/soap4r/) -- My own attempt at incorporating and modernizing the above into GitHub Pages -- still a work in progress at this time.


### Project Motivation

I have a personal vested interest in making this the ***fastest, most reliable*** successor to [NaHi's original Soap4R library](https://github.com/nahi/soap4r), and in maintaining and documenting **Soap4R** to the best of my reasonably expected ability.

Soap4R has received a less-than-stellar reputation amongst the Ruby Community for far too long; and I've grown tired of seeing shoddy advice floating around to abandon **Soap4R** in favor of other SOAP Implementations. That's just nonsense -- especially when you're faced with the challenge of updating large, already-written, revenue-generating systems.

IMHO, NaHi did a freaking brilliant job with **Soap4R**. The code is tight, the Unit Tests are astonishingly comprehensive, and -- aside from finding someone willing to invest time to carry **Soap4R** forward -- there's really no good reason why **Soap4R** should be so neglected.

In fact, I'd much prefer spending time forward-porting **Soap4R** to keep this known-good foundation library going, versus taking on the risky task of migrating already-written applications to a completely new SOAP implementation. Along the way in this journey, I'm adding support for newer XML Parsers like **[Ox](https://github.com/ohler55/ox)** (which is screaming fast, btw!) and **[Nokogiri](https://github.com/sparklemotion/nokogiri)**. I also have future plans to add support for newer HTTP Clients such as **[Curb](https://github.com/taf2/curb)**.

### Why Name This "Soap4R-ng" ?
As felipec/soap4r (now soap2r) has pointed out upon renaming Soap2R, there is a LOT of competition to uniquely name the a "successor" to the original Soap4R. Soap2R came into being because "Soap5R" had already been claimed. :-)

### How to Get a Speed Boost : Use Nokogiri or Ox, not REXML
Be sure to have Nokogiri or Ox available in your Gemset. Soap4R-ng will find and use what's available (Ox has highest precedence, then Nokogiri, falling back to REXML as the last-resort if needed. 

I personally recommend **Nokogiri** as the best performing, most flexible parser at this time, as it handles "special characters" like HTML ampersand-escaped characters internally. Ox doesn't handle such an extensive set of special-characters natively, so to get things up to par, I added **htmlentities** support if it's available when using the Ox parser. Using **htmlentities** with **Ox** in this manner adds a bit of a performance penalty, however.

If you know your incoming XML is "clean", Ox is a really great alternative.

**LibXML** is somewhat broken at this time. It's low-priority on the task list, as **Nokogiri** and **Ox** are more readily available. In fact, I may drop support for the **LibXML** parser in a future release.

***More to come soon*** I'm hammering on getting Soap4R-ng working under Ruby 2.2 (As in "Regression Tests pass with Zero Errors or Warnings") before tackling feature enhancements like **Oga** or **Curb**

### Testing or Contributing
Diving into the Source? Sure, I can always use more eyes to improve the code quality. Welcome aboard!

I assume you know how to check out the Git Repository, set up **rvm** or equivalent environment, and run **Bundler** to pull in the suggested Gems. From there, do a **rake test:surface** to run the smaller set of Unit Tests; or **rake test:deep** to run the complete set of Unit Tests.

