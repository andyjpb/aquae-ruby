require 'openssl'
require_relative 'messagesocket'
require_relative 'encapsulationsocket'

module Aquae
  class Endpoint
    # Runs a TCP server to accept new connections
    # and opens TCP client connections when required.

    def initialize metadata, key, this_node
      metadata = metadata
      node = metadata.node.find {|n| n.name == this_node }
      tcp_server = TCPServer.new node.location.ipAddress, node.location.portNumber
      @context = Endpoint::make_context node, key, metadata
      @ssl_server = OpenSSL::SSL::SSLServer.new tcp_server, @context
    end

    def self.make_context node, key, metadata
      context = OpenSSL::SSL::SSLContext.new
      context.verify_mode = OpenSSL::SSL::VERIFY_PEER
      context.cert_store = Endpoint::make_store metadata
      context.cert = OpenSSL::X509::Certificate.new node.publicKey
      context.key = OpenSSL::PKey::RSA.new key
      context
    end

    def self.make_store metadata
      certs = metadata.node.map(&:publicKey).map(&OpenSSL::X509::Certificate.method(:new))
      store = OpenSSL::X509::Store.new
      certs.each &store.method(:add_cert)
      store.freeze
      store
    end

    def self.make_socket tcp_socket
      Aquae::MessageSocket.new Aquae::EncapsulationSocket.new tcp_socket
    end

    def accept_messages
      raise ArgumentError.new("no block given") unless block_given?
      loop do
        socket = Endpoint::make_socket @ssl_server.accept
        yield socket
      end
    end

    def connect_to node
      tcp_socket = TCPSocket.new node.location.ipAddress, node.location.portNumber
      ssl_socket = OpenSSL::SSL::SSLSocket.new tcp_socket, @context
      ssl_socket.sync_close = true
      Endpoint::make_socket ssl_socket.connect
    end

    def nodes=
      # Updates the metadata used by this endpoint.
      # TODO: Any nodes no longer in the metadata will have
      # their connections closed?
    end
  end
end
