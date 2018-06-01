source 'http://rubygems.org'

if RUBY_VERSION.to_f <= 1.8
  gem 'htmlentities', '4.3.1'       # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  gem 'nokogiri', '~> 1.5.11'       # nokogiriparser ; Uses libxml2, libxslt, and zlib
  gem 'httpclient', '~> 2.7.0.1'
else
  gem 'httpclient'   # 2.1.5.2
  gem 'htmlentities', '~> 4.3.3'    # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  if RUBY_VERSION.to_f <= 2.2
    gem 'nokogiri',     '~> 1.6.6'    # nokogiriparser ; Uses libxml2, libxslt, and zlib
  else
    gem 'nokogiri',   '~> 1.8.2'
  end
  gem 'oga'                         # ogaparser      ; Pure-Ruby Alternative ; Ruby 1.9 and above only.
  gem 'logger-application', :require=>'logger-application'
end

if RUBY_PLATFORM =~ /java/
  gem 'libxml-jruby'                 # libxmlparser (Java Equivalent)
else
  if RUBY_VERSION.to_f <= 1.9
    gem 'libxml-ruby', '~> 2.8.0'
  else
    gem 'libxml-ruby', '~> 3.1.0'
  end
  if RUBY_VERSION.to_f <= 1.8
    gem 'ox', '~> 2.4.5'
  else
    gem 'ox'                          # oxparser       ; Uses its own custom C-library
  end
  gem 'curb'
end

## # Testing Support ###
group :test do
  if RUBY_VERSION.to_f <= 1.8
    gem 'test-unit', '~> 1.2.3'
    gem 'rake', '~> 10.4.2'
  else
    gem 'test-unit'
    gem 'rake'
  end
  if RUBY_VERSION.to_f <= 1.9
    gem 'json', '~> 1.8' # Mostly for Code Climate's benefit if running on Ruby 1.9 or less.
  else
    gem 'json', '~> 2.1'
  end
  gem 'rubyjedi-testunitxml', :git=>'https://github.com/rubyjedi/testunitxml.git', :branch=>'master'
  gem "codeclimate-test-reporter", :require=>nil if RUBY_VERSION.to_f >= 1.9
  
  ### Misc Debugging Aids ###
  # gem 'awesome_print'
  # gem 'rcov'                       # Coverage Test scoring, for more confidence. Do a 'rake rcov:rcov' to yield coverage results.
  # gem 'pry'                        ## see also: pry-debugger for Ruby 1.9 and lower; and pry-byebug for 2.0 and higher (requires byebug gem also)
  # gem 'ruby-termios'               # Unroller requires this . . .
  # gem 'unroller', :git=>'https://github.com/jayjlawrence/unroller.git', :branch=>'master'

  gem 'pry-byebug', '< 3.6' if RUBY_VERSION.to_f >= 2.0
  gem 'byebug', '< 10' if RUBY_VERSION.to_f >= 2.0
  gem 'soap4r-ng', :path=>'.'  # Make our development copy (this directory) available as a Gem via Bundler. Useful for running tests.
end
