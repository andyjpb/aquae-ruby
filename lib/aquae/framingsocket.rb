module Aquae
  class FramingSocket
    # Wraps a streaming connection to a node and performs framing
    def initialize socket
      @socket = socket
    end

    def write chunk
      len = [chunk.size].pack(UINT64_LITTLE_ENDIAN)
      @socket.syswrite len
      @socket.syswrite chunk
    end

    def read
      # Reads and interprets first bytes as an integer,
      # then waits for that many bytes to arrive
      bytes = @socket.sysread(UINT64_SIZE)
      len = bytes.unpack(UINT64_LITTLE_ENDIAN).first
      @socket.sysread len
    end

    private

    UINT64_LITTLE_ENDIAN = "Q>"
    UINT64_SIZE = 8
  end
end
