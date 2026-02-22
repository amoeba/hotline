# frozen_string_literal: true

require "socket"
require "bindata"
require "hotline/version"
require_relative "types"
require_relative "exceptions"

module Hotline
  module Tracker
    class Client
      attr_reader :version

      def initialize(host = nil, port = 5498, version = 1)
        @host = host
        @port = port
        @version = version.to_s
      end

      def to_s
        [
          self.class.name,
          "{host: #{@host}, port: #{@port}, version: #{@version}}"
        ].join("")
      end

      def socket
        @socket ||= begin
          s = TCPSocket.new(@host, @port)
          s.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [20, 0].pack("l_2"))
          s
        end
      end

      def servers
        @servers ||= []
      end

      def fetch
        request = Request.new(version: version.to_i)
        request.write(socket)

        # Verify response, which should be an echo back
        response = Request.read(socket.read(6))
        if response != request
          raise InvalidTrackerResponse
        end

        # Initial response from server
        response = socket.read(8)
        r = Response.read(response)

        # Read the rest of the resposne
        response = socket.read(r.remaining)

        # Make a separate copy in case we fail
        new_servers = []

        # Track the position in the response for us to read each server from
        cursor = 0

        r.n.times do |i|
          server = Server.read(response[cursor..])
          new_servers << server
          cursor += 12 + server.name_len + server.desc_len
        end

        @servers = new_servers
      end
    end
  end
end
