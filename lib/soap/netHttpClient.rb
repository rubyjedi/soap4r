=begin
SOAP4R - net/http wrapper
Copyright (C) 2003 NAKAMURA Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end

require 'net/http'


module SOAP


class NetHttpClient

  attr_accessor :proxy
  attr_accessor :debugDev
  attr_reader :sessionManager

  class SessionManager
    attr_accessor :connectTimeout
    attr_accessor :sendTimeout
    attr_accessor :receiveTimeout
  end

  class Response
    attr_reader :content
    attr_reader :status
    attr_reader :reason
    attr_reader :contentType

    def initialize(res)
      @status = res.code.to_i
      @reason = res.message
      @contentType = res['content-type']
      @content = res.body
    end
  end

  def initialize(proxy = nil, agent = nil)
    @proxy = proxy
    @agent = agent
    @sessionManager = SessionManager.new
  end

  def reset(url)
    # ignored.
  end

  def post(url, sendBody, header)
    url = URI.parse(url)
    extra = header.dup
    extra['User-Agent'] = @agent if @agent
    response = responseBody = nil
    if @proxy
      Net::HTTP::Proxy(@proxy.host, @proxy.port).start(url.host, url.port) { |http|
	if http.respond_to?(:set_debug_output)
	  http.set_debug_output(@debugDev)
	end
	response, responseBody =
	  http.post(url.instance_eval('path_query'), sendBody, extra)
      }
    else
      Net::HTTP.start(url.host, url.port) { |http|
	if http.respond_to?(:set_debug_output)
	  http.set_debug_output(@debugDev)
	end
	response, responseBody =
	  http.post(url.instance_eval('path_query'), sendBody, extra)
      }
    end
    Response.new(response)
  end
end


end
