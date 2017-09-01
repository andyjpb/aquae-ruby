require_relative 'protos/transport.pb.rb'
require_relative 'framingsocket'

module Aquae
  class EncapsulationSocket
    # Wraps a socket and implements the encapsulation protocol.

    def initialize socket
      @socket = socket
      @framer = FramingSocket.new socket
    end

    def read
      header = Transport::Header.decode @framer.read
      payload = @socket.read header.length
      [header.type, payload]
    end

    def write type, payload
      header = Transport::Header.new type: type, length: payload.size
      @framer.write header.encode
      @socket.write payload
      @socket.flush
    end

    def close
      @socket.close
    end
  end
end
