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
        handshake
        header = read_header
        @servers = read_servers(header)
      end

      private

      def handshake
        request = Request.new(version: version.to_i)
        request.write(socket)

        response = Request.read(socket.read(6))
        raise InvalidTrackerResponse if response != request
      end

      def read_header
        Response.read(socket.read(8))
      end

      def read_servers(header)
        data = socket.read(header.remaining)
        servers = []
        cursor = 0

        header.n.times do
          server = Server.read(data[cursor..])
          servers << server
          cursor += 12 + server.name_len + server.desc_len
        end

        servers
      end
    end
  end
end
