#!/usr/bin/env ruby

require 'soap/rpc/standaloneServer'

class Server < SOAP::RPC::StandaloneServer
  class RpcServant
    def rpc_serv(obj1, obj2)
      [obj1, obj2]
    end
  end

  class DocumentServant
    def doc_serv(obj)
      obj
    end
  end

  class GenericServant

    # method name style: requeststyle_requestuse_responsestyle_responseuse

    def rpc_enc_rpc_enc(obj1, obj2)
      [obj1, obj2]
    end

    alias rpc_enc_rpc_lit rpc_enc_rpc_enc

    def rpc_enc_doc_enc(obj1, obj2)
      obj1
    end

    alias rpc_enc_doc_lit rpc_enc_doc_enc

    def doc_enc_rpc_enc(obj)
      [obj, obj]
    end

    alias doc_enc_rpc_lit doc_enc_rpc_enc

    def doc_enc_doc_enc(obj)
      obj
    end

    alias doc_enc_doc_lit doc_enc_doc_enc
  end

  def initialize(*arg)
    super
    add_rpc_servant(RpcServant.new)
    add_document_servant(DocumentServant.new)

    #servant = Servant.new
    # ToDo: too plain: should add bare test case
    #qname ||= XSD::QName.new(@default_namespace, name)
    #add_operation(qname, nil, servant, "rpc_enc_rpc_enc", param_def,
    #  opt(:rpc, :rpc, :encoded, :encoded))
  end

  def opt(request_style, request_use, response_style, response_use)
    {
      :request_style => request_style,
      :request_use => request_use,
      :response_style => response_style,
      :response_use => response_use
    }
  end
end

if $0 == __FILE__
  server = Server.new('Server', 'urn:styleuse', '0.0.0.0', 7000)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
