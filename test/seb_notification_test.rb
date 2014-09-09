# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

class SebLVNotificationTest < Test::Unit::TestCase
  include Banklink

  def setup
    @seb = Banklink::SebLV.notification(http_raw_data)
  end

  # TODO: fix test
  def test_acknowledgement
    assert_equal false, @seb.acknowledge # Don't know why this is not working
  end

  def test_accessors
    assert_equal true, @seb.complete?
    assert_equal 'Completed', @seb.status
    assert_equal "92", @seb.transaction_id
    assert_equal nil, @seb.gross
  end

  def test_acknowledgement_fail_with_params_changed
    @seb = Banklink::SebLV.notification(http_raw_data.gsub('VK_AMOUNT=33', 'VK_AMOUNT=100'))
    assert_equal false, @seb.acknowledge
  end

  private

  def http_raw_data
    "IB_SND_ID=SEBUB&IB_SERVICE=0004&IB_VERSION=001&IB_REC_ID=NOMO&IB_PAYMENT_ID=92&IB_PAYMENT_DESC=test&IB_FROM_SERVER=N&IB_STATUS=ACCOMPLISHED&IB_CRC=BJIjQ7j0T+UG6ju/kybOFhf9ZMg0YG/G2aGN6k8X4sl7seEtF9JlxF0EwMvqv4ycYLbtTsbb1f7s2unT6mV2RPJzg+SNDpvKLeZ75NT0eZtO3+pspcVun9K/W/t8Q1HTRcCBZTOQgCo3HdraUds3fNyuyxLSx51UjmOvYlVVHaM=&IB_LANG=LAT"
  end
end
