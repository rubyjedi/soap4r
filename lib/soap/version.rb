# encoding: UTF-8
module SOAP
  module VERSION #:nodoc:
    MAJOR = 2
    MINOR = 0
    TINY  = 4
    STRING = [MAJOR, MINOR, TINY].join('.')
    
    FORK  = "SOAP4R-NG"
    FORK_STRING = "#{SOAP::VERSION::FORK}/#{SOAP::VERSION::STRING}"
  end
end
