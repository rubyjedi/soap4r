# encoding: UTF-8
# SOAP4R - HTTP client backend registry.

module SOAP
module HTTPBackend

  @@client_class = nil
  @@retryable = false

  def self.client_class
    @@client_class
  end

  def self.retryable?
    @@retryable
  end

  # Called by each backend adapter (lib/soap/httpbackend/*.rb) once it has
  # successfully required its underlying library. Mirrors
  # XSD::XMLParser::Parser.add_factory's self-registration pattern
  # (lib/xsd/xmlparser/parser.rb) -- same shape of problem, one process-wide
  # choice made once at load time.
  def self.register(client_class, retryable)
    if $DEBUG
      puts "Set #{ client_class } as HTTP client backend."
    end
    @@client_class = client_class
    @@retryable = retryable
  end

end
end
