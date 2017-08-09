module Aquae
  class FramingSocket
    # Wraps a streaming connection to a node and performs framing

    def initialize socket
      @socket = socket
    end

    def write chunk
      # Writes a framing header and then the payload
      header = [(FRAMING_VERSION << 4) | 0, chunk.size].pack FRAMING_GRAMMAR
      @socket.syswrite header
      @socket.syswrite chunk
    end

    def read
      # Reads and interprets first bytes as a framing header,
      # and then reads bytes according to the length field
      bytes = @socket.sysread FRAMING_HEADER_SIZE
      version, len = bytes.unpack FRAMING_GRAMMAR
      # TODO: handle the version being wrong
      @socket.sysread len
    end

    private

    FRAMING_VERSION = 0
    FRAMING_GRAMMAR = "CC"
    FRAMING_HEADER_SIZE = 2
  end
end
