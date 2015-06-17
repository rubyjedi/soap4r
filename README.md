# soap4r
Soap4R (as maintained by RubyJedi)

## Danger, Will Robinson!

This is probably the last you will see of my efforts under the "Soap4R" banner.
I am working on releasing a new Gem, Soap4R-ng, which is a MAJOR code refresh of NaHi's Soap4R code.

Highlights of Soap4R-ng (once complete):
* Compatible with Ruby 1.8 thru 2.1
* Support for newer, faster XML Parsers:  Ox (Fully Functional), Nokogiri (Fully Functional), and Oga (Broken; WIP)

## Why Soap4R-ng ?

Well, as felipec/soap4r (now soap2r) has passively pointed out, there is a LOT of contention for the "successor" Gem to the original Soap4R. Soap2R itself was born because the "Soap5R" name was claimed. :-)

Anyway, all work on Soap4R-ng is being done in a different branch (not the "master" branch). Feel free to try it out by pointing your Gemfile to the corresponding WIP branch.

More documentation coming soon.  For now, just know that you need to have Nokogiri or Ox included in your Gemfile so Soap4R-ng can find and use it. :-)
