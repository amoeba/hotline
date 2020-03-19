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
        @socket ||= TCPSocket.new(@host, @port)
      end

      def servers
        @servers ||= []
      end

      def fetch
        # Build a magic number string from the version
        magic = "HTRK\x00" + [version].pack("h")

        socket.write(magic)
        response = socket.recv 6

        # Verify response, which should be an echo back
        if response != magic
          raise InvalidTrackerResponse
        end

        # Initial response from server
        response = socket.recv(8)
        r = Response.read(response)

        # Read the rest of the resposne
        response = socket.recv(r.remaining)

        r.n.times do |i|
          s = Server.read(response)
          servers << s

          # TODO: Fix this to not re-allocate a string every loop?
          response = response[(12 + s.name_len + s.desc_len)..(response.length - 1)]
        end
      end
    end
  end
end
