source 'http://rubygems.org'

gem 'httpclient', '~> 2.1.5.2' # '~> 2.3.4.1' # 2.1.5.2  // NOTE: httpclient 2.3.4.1 has issues with SSL

if RUBY_VERSION.to_f > 1.8
  gem 'logger-application', :require=>'logger-application'
end




## HTML Entities Gem -- Provide/Require this Gem this when OxParser's internal "special-character conversion" isn't good enough for your needs.

if RUBY_VERSION.to_f <= 1.8
  gem 'htmlentities', '4.3.1' # for OxParser
else
  gem 'htmlentities'    # for OxParser
end




### XML Parsers Declarations ###

### XML Parsers that use a C-Library for speed

gem 'ox'                            # oxparser       ; Uses its own custom C-library
if RUBY_VERSION.to_f <= 1.8
  gem 'nokogiri', '~> 1.5.11'       # nokogiriparser ; Uses libxml2, libxslt, and zlib
else
  gem 'nokogiri'                     # nokogiriparser ; Uses libxml2, libxslt, and zlib
end
gem 'libxml-ruby'                   # libxmlparser   ; Uses libxml2 

### XML Parsers that are Pure-Ruby

if RUBY_VERSION.to_f >= 1.9
  gem 'oga'                         # ogaparser
end




### Unit-Testing Support ###
group :test do
  gem 'test-unit', '~> 1.2.3'
  gem 'rubyjedi-testunitxml', :git=>'https://github.com/rubyjedi/testunitxml.git', :branch=>'master'
  
  ### Misc Debugging Aids
  # gem 'rcov'
  # gem 'pry' ## see also: pry-debugger for Ruby 1.9 and lower; and pry-byebug for 2.0 and higher (requires byebug gem also)
  # gem 'ruby-termios' # for unroller
  # gem 'unroller', :git=>'https://github.com/jayjlawrence/unroller.git', :branch=>'master'
  gem 'awesome_print'
end
