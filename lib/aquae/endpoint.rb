module Aquae
  class Endpoint
    # Runs a TCP server to accept new connections
    # and opens TCP client connections when required.

    def initialize
      @tcp_server = TCPServer.new 'localhost', 12345
    end

    def make_socket tcp_socket
      Aquae::MessageSocket.new Aquae::EncapsulationSocket.new tcp_socket
    end

    def accept_messages
      raise ArgumentError.new("no block given") unless block_given?
      loop do
        socket = make_socket @tcp_server.accept
        yield socket
      end
    end

    def nodes=
      # Updates the metadata used by this endpoint.
      # TODO: Any nodes no longer in the metadata will have
      # their connections closed?
    end
  end
end
