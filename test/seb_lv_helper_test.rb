# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

class SebLVHelperTest < Test::Unit::TestCase
  include Banklink

  def test_should_create_fields_for_0002
    options = {}
    options[:amount] = '1.55'
    options[:currency] = 'LVL'
    options[:return] = 'http://default/'
    options[:reference] = '54'
    options[:message] = 'Pay for smtx'

    helper = SebLV::Helper.new(300, '300', options)
    assert_equal 11, helper.form_fields.size
  end

end
