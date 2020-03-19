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

        # Make a separate copy in case we fail
        new_servers = []

        # Track the position in the response for us to read each server from
        cursor = 0

        r.n.times do |i|
          server = Server.read(response[cursor..(response.length - 1)])
          new_servers << server
          cursor += 12 + server.name_len + server.desc_len
        end

        @servers = new_servers
      end
    end
  end
end
