# BanklinkGS
Provides Swedbank and SEB payment functionality.
Implements Banklink by spec version 1.4 (specifically, service 1012) as of 2016-10-03.  
See included PDF file in /Banklink1.4.pdf.  

# Requirements
Ruby 2.0.0 and greater.  
activesupport gem.  

# Installation

```ruby
# in Gemfile
gem 'banklink_gs', git: 'git@github.com:CreativeGS/banklink_gs.git', branch: 'master' # and bundle
```

# Usage
## General helper->response pattern
Coming soon.

## Swedbank EE version 1.4
NB, as of 2016-10-03, EE Swedbank uses the 1.4 Banklink spec via `Swedbank14` module.  
Consult `Banklink1.4.pdf` and `EE REF number generation` (obtained from http://pangaliit.ee/en/settlements-and-standards/reference-number-of-the-invoice) in `/documentation` directory.  
All other paymodes use their respective legacy counterparts.   

The flow is:  

1. In controller, prepare the form helper object
  ```rb
  if some_condition
    merchant_id = "TRADER"      
  else
    merchant_id = "OTHER_TRADER"  
  end

  Banklink::Swedbank14.privkey = File.read("#{Rails.root}/secret/banklink/swedbank/#{merchant_id}/privkey.pem")
  Banklink::Swedbank14.bank_cert = File.read("#{Rails.root}/secret/banklink/swedbank/#{merchant_id}/bank_cert.pem")

  options = {
    merchant_id: merchant_id,
    order_id: "1234567", # goes in "VK_STAMP"
    payment_id: "6699", # goes in "VK_REF"
    amount: "1.99",
    message: "Thanks for your purchase, your unique order number is 1234567",
    success_url: "https://domain.com/success/path",
    fail_url: "https://domain.com/fail/path",
  }

  swed14_helper = Banklink::Swedbank14::Helper.new(options)
  ```

2. In respective template render a form that posts to Banklink endpoint
  ```html
  <html>
  <body>
  <body onload="document.swdForm.submit();" style="display:none;">
    <form method="POST" name="swdForm" action="<%= swed14_helper.service_url %>">
      <% swed14_helper.form_fields.each do |field, value| %>
         <%= hidden_field_tag(field, value) %>
      <% end %>
    </form>
  </body>
  </html>
  ```

3. With correct communication *to* the bank in step 2, there can be 3 types of response *from* bank.  
  a. GET about success, performed by bank server headlessly
  b. POST about success, performed by user's browser
  c. GET/POST about failure

4. Either way, pass returned parameters to response builder in return actions:
  ```rb
  response = Banklink::Swedbank14::Response.new(params)

  # this service object then exposes needed convenience fields & methods:
  :complete?
  :status
  :item_id
  :params
  :sender_name
  :sender_bank_account
  :received_at  
  :redirect?    
  ```

# Authors
This gem was last updated and is maintained by Creative's [Augusts Bautra](https://github.com/Epigene).  
Previously developed by {Sacristan @ Creative}[mailto:girts@creo.mobi].  
Original code by [Artūrs Braučs](github.com/artursbraucs/banklink).  
