# encoding: UTF-8
module SOAP
  module VERSION #:nodoc:
    MAJOR = 2
    MINOR = 1
    TINY  = 0
    STRING = [MAJOR, MINOR, TINY].join('.')
    
    FORK  = "SOAP4R-NG"
    FORK_STRING = "#{SOAP::VERSION::FORK}/#{SOAP::VERSION::STRING}"
  end
end
