require "test_helper"

class HotlineTrackerClientTest < Minitest::Test
  def test_we_can_create_a_tracker_client
    client = Hotline::Tracker::Client.new("localhost", "5000")
    refute_nil client
    assert_instance_of Hotline::Tracker::Client, client
  end

  def test_we_can_print_the_client
    client = Hotline::Tracker::Client.new("localhost", "5000")

    assert_instance_of String, client.to_s
  end
end
