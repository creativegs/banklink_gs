require File.dirname(__FILE__) + '/test_helper'

class SebTest < Test::Unit::TestCase
  include Banklink

  def should_return_correct_service_url
    assert_equal nil, Banklink::Seb.service_url
    
    Banklink::SebLV.service_url = "SebLT"
    assert_equal "SebLT", Banklink::Seb.service_url

    Banklink::SebLV.service_url = "SebLV"
    assert_equal "SebLV", Banklink::Seb.service_url
  end
end