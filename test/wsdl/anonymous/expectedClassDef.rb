require 'xsd/qname'

module WSDL; module Anonymous


# {urn:lp}ExtraInfo
class ExtraInfo < ::Array

  # {}Entry
  #   key - SOAP::SOAPString
  #   value - SOAP::SOAPString
  class Entry
    attr_accessor :key
    attr_accessor :value

    def initialize(key = nil, value = nil)
      @key = key
      @value = value
    end
  end
end

# {urn:lp}loginResponse
#   loginResult - LoginResponse::LoginResult
class LoginResponse

  # inner class for member: loginResult
  # {}loginResult
  #   sessionID - SOAP::SOAPString
  class LoginResult
    attr_accessor :sessionID

    def initialize(sessionID = nil)
      @sessionID = sessionID
    end
  end

  attr_accessor :loginResult

  def initialize(loginResult = nil)
    @loginResult = loginResult
  end
end

# {urn:lp}login
#   loginRequest - Login::LoginRequest
class Login

  # inner class for member: loginRequest
  # {}loginRequest
  #   username - SOAP::SOAPString
  #   password - SOAP::SOAPString
  #   timezone - SOAP::SOAPString
  class LoginRequest
    attr_accessor :username
    attr_accessor :password
    attr_accessor :timezone

    def initialize(username = nil, password = nil, timezone = nil)
      @username = username
      @password = password
      @timezone = timezone
    end
  end

  attr_accessor :loginRequest

  def initialize(loginRequest = nil)
    @loginRequest = loginRequest
  end
end


end; end
