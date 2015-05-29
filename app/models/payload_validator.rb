require 'json'
require 'pry'

class PayloadValidator #< Payload
  attr_reader :identifier

  def initialize(data, identifier)
    @hashed = Digest::SHA1.hexdigest(data)
    @data = JSON.parse(data)
    # JSON.parse(data)
    # @payload = Payload.new(requested_at: data["requestedAt"])
    @identifier = identifier
  end

  def validate
    if identified_source = Source.find_by_identifier(identifier)
      if identified_source.payloads.find_by_payhash(@hashed)
        result = { status: 403, body: "Already Received Request" }
      else
        binding.pry
        identified_source.payloads.create(normalized_payload)   #changed.create to .new to set up the table values
        result = { status: 200, body: "success"}
      end
    else
      result = { status: 403, body: "Application Not Registered"}
    end
    result
  end

  private

  def normalized_payload
    {
      :url => @data["url"],
      :requested_at => DateTime.parse(@data["requestedAt"]).utc, # FYI - ActiveRecord all values in DB stored in UTC
      :responded_in => @data["respondedIn"],
      :referred_by => @data["referredBy"],
      :request_type => @data["requestType"],
      :event_name => @data["eventName"],
      :user_agent => @data["userAgent"],
      :resolution_width => @data["resolutionWidth"],
      :resolution_height => @data["resolutionHeight"],
      :ip => @data["ip"]
    }
  end


end
