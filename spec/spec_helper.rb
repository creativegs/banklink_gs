require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'banklink'
require 'test_data.rb'
require 'timecop'
require "pry"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:all) do
    Time.zone = ActiveSupport::TimeZone.new("Riga")
  end
end

def valid_swed_14_options
  return {
    merchant_id: "TRADER", #"STOCK", # or "SWISSLAN"
    order_id: "1234567890",
    payment_id: "666999",
    amount: "1.99",
    message: "Thanks!",
    success_url: "https://testtest.ee/banklinkreturn.php",
    fail_url: "https://testtest.ee/banklinkcancel.php",
  }
end

def valid_swed_14_options_no_message
  return {
    merchant_id: "TRADER", #"STOCK", # or "SWISSLAN"
    order_id: "1234567890",
    payment_id: "666999",
    amount: "1.99",
    message: "",
    success_url: "https://testtest.ee/banklinkreturn.php",
    fail_url: "https://testtest.ee/banklinkcancel.php",
  }
end

def swed_14_completed_response
  return {
    "VK_SERVICE" => "1111",
    "VK_VERSION" => "008",
    "VK_SND_ID" => "SWEDBANK",
    "VK_REC_ID" => "TRADER",
    "VK_STAMP" => "1234567890",

    "VK_T_NO" => "11111",
    "VK_AMOUNT" => "1.99",
    "VK_CURR" => "EUR",
    "VK_REC_ACC" => "1111222233333",
    "VK_REC_NAME" => "recipient",
    "VK_SND_ACC" => "999988887777",
    "VK_SND_NAME" => "remitter",

    "VK_REF" => "6669995",
    "VK_MSG" => "test message",
    "VK_T_DATETIME" => "2014-10-10T09:25:52+0300",

    "VK_MAC" => "TODO",
    "VK_ENCODING" => "UTF-8",
    "VK_LANG" => "ENG",
    "VK_AUTO" => "N",
  }
end

def swed_14_failed_response
  return {
    "VK_SERVICE" => "1911",
    "VK_VERSION" => "008",
    "VK_SND_ID" => "SWEDBANK",
    "VK_REC_ID" => "TRADER",
    "VK_STAMP" => "1234567890",

    "VK_REF" => "6669995",
    "VK_MSG" => "test message",

    "VK_MAC" => "TODO",
    "VK_ENCODING" => "UTF-8",
    "VK_LANG" => "ENG",
    "VK_AUTO" => "N",
  }
end
