module Zet
class B64
  def self.encode(data, urlsafe=false)
    urlsafe ? Base64.urlsafe_encode64(data) : Base64.encode64(data)
  end

  def self.decode(data, urlsafe=false)
    urlsafe ? Base64.urlsafe_decode64(data) : Base64.decode64(data)
  end
end
end

