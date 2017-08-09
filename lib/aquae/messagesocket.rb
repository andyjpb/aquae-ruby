module Aquae
  class MessageSocket
    # Wraps a FramingSocket and performs de/serialisation of messages

    def initialize message_type, framing_socket
      # @param MessageType [Class] The type of Protobuf message to try and deserialise
      # @param framing_socket [FramingSocket] An open socket which returns one message per call to read
      @Type = message_type
      @socket = framing_socket
    end

    def write message
      unless message.is_a? @Type
        raise TypeError.new "Message of type #{message.class} passed, expecting #{@Type}"
      end

      @socket.write @Type.encode message
    end

    def read
      @Type.decode @socket.read
    rescue Protobuf::Error
      # TODO: log error? or send it upwards?
    end
  end
end