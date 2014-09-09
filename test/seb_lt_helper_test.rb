# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

class SebLTHelperTest < Test::Unit::TestCase
  include Banklink

  def test_should_create_fields_for_1001
    options = {}
    options[:amount] = '1.55'
    options[:currency] = 'LTL'
    options[:return] = 'http://default/'
    options[:reference] = '54'
    options[:message] = 'Pay for smtx'
    options[:acc] = 'LT417044060001223597'

    helper = SebLT::Helper.new(300, '300', options)
    assert_equal 12, helper.form_fields.size
  end

end
