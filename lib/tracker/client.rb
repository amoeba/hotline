# frozen_string_literal: true

require "socket"
require "bindata"
require "hotline/version"
require_relative "types"
require_relative "exceptions"

module Hotline
  module Tracker
    class Client
      def initialize(host = nil, port = 5498)
        @host = host
        @port = port
      end

      def to_s
        "#{self.class.name}(host: #{@host}, port: #{@port})"
      end

      def socket
        @socket ||= TCPSocket.new(@host, @port)
      end

      def servers
        @servers ||= []
      end

      def fetch
        socket.write("HTRK\x00\x01")

        # Check echo back from tracker
        response = socket.recv 6

        if response != "HTRK\x00\x01"
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
