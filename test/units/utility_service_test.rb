require 'test_plugin_helper'

class UtilitiesServiceTest < ActiveSupport::TestCase
  test "parses empty and nil input as 0" do
    assert_equal ForemanDocker::Utility.parse_memory(""), 0
    assert_equal ForemanDocker::Utility.parse_memory(nil), 0
    assert_equal ForemanDocker::Utility.parse_memory("        "), 0
  end

  test "correctly parses a number without unit" do
    assert_equal ForemanDocker::Utility.parse_memory("1234"), 1_234
    assert_equal ForemanDocker::Utility.parse_memory("  123 4     "), 1_234
  end

  test "correctl parses number with unit" do
    assert_equal ForemanDocker::Utility.parse_memory("10K"), 10_240
    assert_equal ForemanDocker::Utility.parse_memory("20k"), 20_480
    assert_equal ForemanDocker::Utility.parse_memory("5 G"), 5_368_709_120
    assert_equal ForemanDocker::Utility.parse_memory("10m"), 10_485_760
  end

  test "raises on bad input" do
    assert_raise RuntimeError do
      ForemanDocker::Utility.parse_memory("26V")
    end
  end
end
