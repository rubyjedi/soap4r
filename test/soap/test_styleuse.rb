require 'test/unit'
require 'soap/rpc/httpserver'
require 'soap/rpc/driver'


module SOAP


class TestStyleUse < Test::Unit::TestCase
  class GenericServant
    # method name style: requeststyle_requestuse_responsestyle_responseuse

    # 2 params -> array
    def rpc_enc_rpc_enc(obj1, obj2)
      [obj1, obj2]
    end
    alias doc_enc_doc_enc rpc_enc_rpc_enc

    # 2 hashes -> array
    def rpc_lit_rpc_enc(obj1, obj2)
      [obj1.keys, obj2.keys]
    end
    alias doc_lit_doc_enc rpc_lit_rpc_enc

    # 2 params -> 2 hashes
    def rpc_enc_rpc_lit(obj1, obj2)
      return {'obj1' => obj1.class.name}, {'obj2' => obj2.class.name}
    end
    alias doc_enc_doc_lit rpc_enc_rpc_lit

    # 2 hashes -> 2 hashes
    def rpc_lit_rpc_lit(obj1, obj2)
      return obj1, obj2
    end
    alias doc_lit_doc_lit rpc_lit_rpc_lit
  end

  Namespace = "urn:styleuse"

  module Op
    def self.opt(request_style, request_use, response_style, response_use)
      {
        :request_style => request_style,
        :request_use => request_use,
        :response_style => response_style,
        :response_use => response_use
      }
    end

    Op_rpc_enc_rpc_enc = [
      XSD::QName.new(Namespace, 'rpc_enc_rpc_enc'),
      nil,
      'rpc_enc_rpc_enc', [
        ['in', 'obj1', nil],
        ['in', 'obj2', nil],
        ['retval', 'return', nil]],
      opt(:rpc, :encoded, :rpc, :encoded)
    ]

    Op_rpc_lit_rpc_enc = [
      XSD::QName.new(Namespace, 'rpc_lit_rpc_enc'),
      nil,
      'rpc_lit_rpc_enc', [
        ['in', 'obj1', nil],
        ['in', 'obj2', nil],
        ['retval', 'return', nil]],
      opt(:rpc, :literal, :rpc, :encoded)
    ]

    Op_rpc_enc_rpc_lit = [
      XSD::QName.new(Namespace, 'rpc_enc_rpc_lit'),
      nil,
      'rpc_enc_rpc_lit', [
        ['in', 'obj1', nil],
        ['in', 'obj2', nil],
        ['retval', 'ret1', nil],
        ['out', 'ret2', nil]],
      opt(:rpc, :encoded, :rpc, :literal)
    ]

    Op_rpc_lit_rpc_lit = [
      XSD::QName.new(Namespace, 'rpc_lit_rpc_lit'),
      nil,
      'rpc_lit_rpc_lit', [
        ['in', 'obj1', nil],
        ['in', 'obj2', nil],
        ['retval', 'ret1', nil],
        ['out', 'ret2', nil]],
      opt(:rpc, :literal, :rpc, :literal)
    ]

    Op_doc_enc_doc_enc = [
      Namespace + 'doc_enc_doc_enc',
      'doc_enc_doc_enc', [
        ['in', 'obj1', [nil, Namespace, 'obj1']],
        ['in', 'obj2', [nil, Namespace, 'obj2']],
        ['out', 'ret1', [nil, Namespace, 'ret1']],
        ['out', 'ret2', [nil, Namespace, 'ret2']]],
      opt(:document, :encoded, :document, :encoded)
    ]

    Op_doc_lit_doc_enc = [
      Namespace + 'doc_lit_doc_enc',
      'doc_lit_doc_enc', [
        ['in', 'obj1', [nil, Namespace, 'obj1']],
        ['in', 'obj2', [nil, Namespace, 'obj2']],
        ['out', 'ret1', [nil, Namespace, 'ret1']],
        ['out', 'ret2', [nil, Namespace, 'ret2']]],
      opt(:document, :literal, :document, :encoded)
    ]

    Op_doc_enc_doc_lit = [
      Namespace + 'doc_enc_doc_lit',
      'doc_enc_doc_lit', [
        ['in', 'obj1', [nil, Namespace, 'obj1']],
        ['in', 'obj2', [nil, Namespace, 'obj2']],
        ['out', 'ret1', [nil, Namespace, 'ret1']],
        ['out', 'ret2', [nil, Namespace, 'ret2']]],
      opt(:document, :encoded, :document, :literal)
    ]

    Op_doc_lit_doc_lit = [
      Namespace + 'doc_lit_doc_lit',
      'doc_lit_doc_lit', [
        ['in', 'obj1', [nil, Namespace, 'obj1']],
        ['in', 'obj2', [nil, Namespace, 'obj2']],
        ['out', 'ret1', [nil, Namespace, 'ret1']],
        ['out', 'ret2', [nil, Namespace, 'ret2']]],
      opt(:document, :literal, :document, :literal)
    ]
  end

  include Op

  class Server < ::SOAP::RPC::HTTPServer
    include Op

    def on_init
      @servant = GenericServant.new
      add_rpc_operation(@servant, *Op_rpc_enc_rpc_enc)
      add_rpc_operation(@servant, *Op_rpc_lit_rpc_enc)
      add_rpc_operation(@servant, *Op_rpc_enc_rpc_lit)
      add_rpc_operation(@servant, *Op_rpc_lit_rpc_lit)
      add_document_operation(@servant, *Op_doc_enc_doc_enc)
      add_document_operation(@servant, *Op_doc_lit_doc_enc)
      add_document_operation(@servant, *Op_doc_enc_doc_lit)
      add_document_operation(@servant, *Op_doc_lit_doc_lit)
    end
  end

  Port = 17171

  def setup
    setup_server
    setup_client
  end

  def setup_server
    @server = Server.new(
      :Port => Port,
      :AccessLog => [],
      :SOAPDefaultNamespace => Namespace
    )
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_client
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/", Namespace)
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_rpc_operation(*Op_rpc_enc_rpc_enc)
    @client.add_rpc_operation(*Op_rpc_lit_rpc_enc)
    @client.add_rpc_operation(*Op_rpc_enc_rpc_lit)
    @client.add_rpc_operation(*Op_rpc_lit_rpc_lit)
    @client.add_document_operation(*Op_doc_enc_doc_enc)
    @client.add_document_operation(*Op_doc_lit_doc_enc)
    @client.add_document_operation(*Op_doc_enc_doc_lit)
    @client.add_document_operation(*Op_doc_lit_doc_lit)
  end

  def teardown
    teardown_server
    teardown_client
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def teardown_client
    @client.reset_stream
  end

  def start_server_thread(server)
    t = Thread.new {
      Thread.current.abort_on_exception = true
      server.start
    }
    while server.status != :Running
      sleep 0.1
      unless t.alive?
        t.join
        raise
      end
    end
    t
  end

  def test_rpc_enc_rpc_enc
    assert_equal(
      [1, [2]],
      @client.rpc_enc_rpc_enc(1, [2])
    )
  end

  def test_rpc_lit_rpc_enc
    assert_equal(
      [["a"], ["c"]],
      @client.rpc_lit_rpc_enc({'a' => 'b'}, {'c' => 'd'})
    )
  end

  def test_rpc_enc_rpc_lit
    assert_equal(
      [{'obj1' => 'String'}, {'obj2' => 'Fixnum'}],
      @client.rpc_enc_rpc_lit('a', 1)
    )
  end

  def test_rpc_lit_rpc_lit
    assert_equal(
      [{'a' => 'b'}, {'c' => 'd'}],
      @client.rpc_lit_rpc_lit({'a' => 'b'}, {'c' => 'd'})
    )
  end

  def test_doc_enc_doc_enc
    assert_equal(
      [1, [2]],
      @client.doc_enc_doc_enc(1, [2])
    )
  end

  def test_doc_lit_doc_enc
    assert_equal(
      [["a"], ["c"]],
      @client.doc_lit_doc_enc({'a' => 'b'}, {'c' => 'd'})
    )
  end

  def test_doc_enc_doc_lit
    assert_equal(
      [{'obj1' => 'String'}, {'obj2' => 'Fixnum'}],
      @client.doc_enc_doc_lit('a', 1)
    )
  end

  def test_doc_lit_doc_lit
    assert_equal(
      [{'a' => 'b'}, {'c' => 'd'}],
      @client.doc_lit_doc_lit({'a' => 'b'}, {'c' => 'd'})
    )
  end
end


end
