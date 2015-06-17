source 'http://rubygems.org'

gem 'httpclient'   # 2.1.5.2
gem 'ox'                            # oxparser       ; Uses its own custom C-library
gem 'libxml-ruby'                   # libxmlparser   ; Uses libxml2 

if RUBY_VERSION.to_f <= 1.8
  gem 'htmlentities', '4.3.1'       # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  gem 'nokogiri', '~> 1.5.11'       # nokogiriparser ; Uses libxml2, libxslt, and zlib
else
  gem 'htmlentities', '~> 4.3.3'    # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  gem 'nokogiri',     '~> 1.6.6'    # nokogiriparser ; Uses libxml2, libxslt, and zlib
  gem 'oga'                         # ogaparser      ; Pure-Ruby Alternative ; Ruby 1.9 and above only.

  gem 'logger-application', :require=>'logger-application'
end



## # Testing Support ###
group :test do
  if RUBY_VERSION.to_f <= 1.8
    gem 'test-unit', '~> 1.2.3'
  else
    gem 'test-unit', '~> 1.2.3'      # Could be nice to bump up test-unit version, but test-unit 3.x.x prevents testunitxml from loading.
  end

  gem 'rubyjedi-testunitxml', :git=>'https://github.com/rubyjedi/testunitxml.git', :branch=>'master'
  
  ### Misc Debugging Aids ###
  gem 'awesome_print'

  # gem 'rcov'                       # Coverage Test scoring, for more confidence. Do a 'rake rcov:rcov' to yield coverage results.

  # gem 'pry'                        ## see also: pry-debugger for Ruby 1.9 and lower; and pry-byebug for 2.0 and higher (requires byebug gem also)
  # gem 'ruby-termios'               # Unroller requires this . . .
  # gem 'unroller', :git=>'https://github.com/jayjlawrence/unroller.git', :branch=>'master'
end
