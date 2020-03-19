# frozen_string_literal: true

require "test_helper"

class HotlineTrackerClientTest < Minitest::Test
  def test_we_can_create_a_tracker_client
    client = Hotline::Tracker::Client.new("localhost")
    refute_nil client
    assert_instance_of Hotline::Tracker::Client, client
  end

  def test_we_can_print_the_client
    client = Hotline::Tracker::Client.new("localhost")

    assert_instance_of String, client.to_s
    assert_equal "Hotline::Tracker::Client(host: localhost, port: 5498)", client.to_s
  end

  def test_servers_are_empty_after_init
    client = Hotline::Tracker::Client.new("localhost")

    assert_instance_of Array, client.servers
    assert_equal [], client.servers
  end
end
