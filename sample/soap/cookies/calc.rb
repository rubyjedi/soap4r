class CookieCalcService
  def initialize
    @client_id = 0
    @value = {}
  end

  def set(value)
    @value[get_client_id] = value
  end

  def get
    @value[get_client_id]
  end

  def +(rhs)
    get + rhs
  end

  def -(rhs)
    get - rhs
  end

  def *(rhs)
    get * rhs
  end

  def /(rhs)
    get / rhs
  end

private

  def get_client_id
    if cookie = SOAP::RPC::SOAPlet.cookies.find { |cookie| cookie.name == 'client_id' }
      cookie.expires = Time.now + 3600
      client_id = cookie.value
    else
      client_id = assign_new_client_id
      cookie = WEBrick::Cookie.new('client_id', client_id)
      cookie.expires = Time.now + 3600
      SOAP::RPC::SOAPlet.cookies << cookie
    end
    p "assined client id: #{client_id}"
    client_id
  end

  def assign_new_client_id
    @client_id += 1
    @client_id.to_s
  end

end
