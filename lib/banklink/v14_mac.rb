module V14Mac
  # Calculation using method VK_VERSION=008:
  # VK_MAC is RSA signature of the request fields coded into BASE64.
  # VK_MAC will be calculated using secret key of the sender using RSA. Signature will
  # be calculated for string that consists of all field lengths and contents in the query. Also
  # empty fields are used in calculation and produce a '000' piece.

  # MAC(x1,x2,...,xn) := RSA( SHA-1(p(x1 )|| x1|| p(x2 )|| x2 || ... ||p( xn )||xn),d,n)
  # where:
  # || is string concatenation mark
  # x1, x2, ..., xn are parameters of the query
  # p(x) is length of the field x represented by three digits
  # d is RSA secret exponent
  # n is RSA modulus
  extend ActiveSupport::Concern
  # p(x) is length of the field x represented by three digits
  def func_p(val)
    sprintf("%03i", val.to_s.length)
  end

  # Generate a string to be signed out of service message parameters.
  # p(x1 )|| x1|| p(x2 )|| x2 || ... ||p( xn )||xn
  # || is string concatenation mark
  # p(x) is length of the field x represented by three digits
  # Parameters val, val2, value3 would be turned into:
  # '003val004val2006value3'
  def generate_hasheable_row
    return hasheable_fields.map do |key, value|
      "#{func_p(value)}#{value}"
    end.join("")
  end

  def generate_v14_mac
    privkey = get_private_key
    signature = privkey.sign(OpenSSL::Digest::SHA1.new, generate_hasheable_row)

    return Base64.encode64(signature).gsub(/\n/, '')
  end  
end
