require 'rake/gempackagetask'
require 'rake/testtask'

task :default => 'test:deep'

## ---------------------------------------------------------------------------------------------------- ##
## Gem Packaging
## ---------------------------------------------------------------------------------------------------- ##

load 'soap4r.gemspec'
Rake::GemPackageTask.new(SPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

## ---------------------------------------------------------------------------------------------------- ##
## Unit Testing
## run against the soap4r library for the given Comma-Separated List of Test Scopes. 
##   rake test:deep [SCOPE=soap,wsdl,...]
## Also accepts WARNINGS and VERBOSE as environment variables to control the level of debugging output.
## ---------------------------------------------------------------------------------------------------- ##
namespace :test do
  desc 'Run the complete set of tests' #  
  Rake::TestTask.new(:deep) do |t|
    
    test_scope = ENV['SCOPE'] || '*'
    t.test_files = FileList[ test_scope.split(',').collect{|scope| "test/#{scope}/**/test_*.rb"} ]
  
    t.warning = !!ENV['WARNINGS']
    t.verbose = !!ENV['VERBOSE']
  end
  
  desc 'Run the minimum set of tests'
  Rake::TestTask.new(:surface) do |t|
    
    test_scope = ENV['SCOPE'] || '*'
    t.test_files = FileList[ test_scope.split(',').collect{|scope| "test/#{scope}/test_*.rb"} ]
  
    t.warning = !!ENV['WARNINGS']
    t.verbose = !!ENV['VERBOSE']
  end
end