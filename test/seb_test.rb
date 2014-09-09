class SebTest < Test::Unit::TestCase
  def should_return_correct_service_url
    assert_equal nil, Seb.service_url
    SebLT.service_url = "SebLT"
    assert_equal "SebLT", Seb.service_url
    SebLV.service_url = "SebLV"
    assert_equal "SebLV", Seb.service_url
  end
end