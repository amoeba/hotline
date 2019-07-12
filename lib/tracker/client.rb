require "hotline/version"

module Hotline
  module Tracker
    class Client
      def initialize(host, port)
        @host = host
        @port = port
      end

      def to_s
        "Hotline::Tracker::Client(host=#{@host}:#{@port})"
      end
    end
  end
end
