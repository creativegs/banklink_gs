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
    payment_id: "1234567890",
    amount: "1.99",
    message: "Thanks!",
    success_url: "https://testtest.ee/banklinkreturn.php",
    fail_url: "https://testtest.ee/banklinkcancel.php",
  }
end

def valid_swed_14_options_no_message
  return {
    merchant_id: "TRADER", #"STOCK", # or "SWISSLAN"
    payment_id: "1234567890",
    amount: "1.99",
    message: "",
    success_url: "https://testtest.ee/banklinkreturn.php",
    fail_url: "https://testtest.ee/banklinkcancel.php",
  }
end
