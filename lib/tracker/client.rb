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
        @servers = []

        @state = :BEGIN

        @states = [
          :BEGIN,
          :RECV_MAGIC,
          :RECV_RESPONSE,
          :RECV_SERVERS,
          :DONE
        ]

        @bytes_required = {
          :BEGIN => 0,
          :RECV_MAGIC => 6,
          :RECV_RESPONSE => 8,
          :RECV_SERVERS => 0, # 0? not sure what I wanna do here,
          :DONE => 0
        }

        @buffer = nil
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

      def consume_last_message
        @buffer.slice!(0...@bytes_required[@state])
      end

      def fetch
        response = nil

        until @state == :DONE
          @buffer = socket.recv(@bytes_required[@state]) unless @state == :BEGIN or @state == :DONE

          case @state
          when :BEGIN
            magic = "HTRK\x00" + [version].pack("h")
            socket.write(magic)

            @state = :RECV_MAGIC
          when :RECV_MAGIC
            if (@buffer.length < @bytes_required[@state])
              break
            end

            # Verify response, which should be an echo back
            if @buffer[0..@bytes_required[@state] - 1] != magic
              raise InvalidTrackerResponse
            end

            consume_last_message

            @state = :RECV_RESPONSE
          when :RECV_RESPONSE

            if (@buffer.length < @bytes_required[@state])
              next
            end

            response = Response.read(@buffer)
            nservers = response[:n]

            consume_last_message

            # Dyanmically determine size of next recv?
            @bytes_required[:RECV_SERVERS] = response[:remaining] - 4 # Why - 4?

            @state = :RECV_SERVERS
          when :RECV_SERVERS
            if (@buffer.length < @bytes_required[@state])
              next
            end

            cursor = 0

            response[:n].times do |i|
              server = Server.read(@buffer[cursor..(@buffer.length - 1)])
              @servers << server
              cursor += 12 + server.name_len + server.desc_len
            end

            @state = :DONE
          end
        end
      end
    end
  end
end
