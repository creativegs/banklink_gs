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
    lang: "EST"
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

def swed_14_valid_response
  # a live response for processing of order #1846502, transaction #675798
  return {
    "VK_SERVICE"=>"1111", "VK_VERSION"=>"008", "VK_SND_ID"=>"HP", "VK_REC_ID"=>"STOCK",
    "VK_STAMP"=>"1846502", "VK_T_NO"=>"380", "VK_AMOUNT"=>"0.05", "VK_CURR"=>"EUR",
    "VK_REC_ACC"=>"EE132200221064230307", "VK_REC_NAME"=>"CONTENT DISTRIBUTION SIA", "VK_SND_ACC"=>"EE812200001105126040", "VK_SND_NAME"=>"KRISTJAN MÄNNIK",
    "VK_REF"=>"6757988", "VK_MSG"=>"StockholmHealth.com 675798 - Helpdesk 0037120023472 or diet@stockholmhealth.com", "VK_T_DATETIME"=>"2016-10-06T13:26:27+0300",
    # verification line
    "VK_LANG"=>"EST", "VK_AUTO"=>"Y", "VK_MAC"=>"eaLlayEFqM68XV7EyP3A+NtIXz4EbHQCADs4NtxKWstRLXdu9+LIyluo/tpAu4ChlnjLxl5gwFq+kBaw0QjYPlJkbyPKP7v3PBotjdVV3LNDfiZrZF+YGqtJ/HsBDh1+06w+cchQTMRj+cD8WEWolw8neX/6hTbb+B3hwWHRDHQ=", "VK_ENCODING"=>"UTF-8"
  }
end

def valid_response_signable_row
  return "0041111003008002HP005STOCK" +
  "00718465020033800040.05003EUR" +
  "020EE132200221064230307024CONTENT DISTRIBUTION SIA020EE812200001105126040015KRISTJAN MÄNNIK" +
  "0076757988079StockholmHealth.com 675798 - Helpdesk 0037120023472 or diet@stockholmhealth.com" +
  "0242016-10-06T13:26:27+0300"
end

def swed_14_invalid_response
  # a live response for processing of order #1846502, transaction #675798, differs from valid response by sender acc number
  return swed_14_valid_response.merge({"VK_SND_ACC"=>"EE812200001105126041"})
end

def swed_bank_cert
  return File.read("#{Banklink::ROOT}/spec/crypto/bank_cert.pem")
end
