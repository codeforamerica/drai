class FakeTwilioClient
  # HT Thoughtbot: https://robots.thoughtbot.com/testing-sms-interactions

  cattr_accessor :messages
  attr_accessor :create_error
  self.messages = []

  def initialize(*_args)
  end

  def messages
    self
  end

  def create(args)
    if create_error
      raise create_error
    end

    message = FakeTwilioMessage.new(args.merge(sid: 'FAKE_TWILIO_SID'))
    self.class.messages << message
    if Rails.env.development?
      puts "\n\nSMS message that would have been sent:\n"
      puts "TO: #{args[:to]}"
      puts "FROM: #{args[:from]}"
      puts "BODY: #{args[:body]}\n\n"
    end
    message
  end

  def api
  end

  def lookups
    FakeTwilioLookups.new
  end

  def calls
    FakeTwilioCalls.new
  end
end

class FakeTwilioCalls
  cattr_accessor :calls
  self.calls = []

  def create(args)
    calls << args
    args
  end
end

class FakeTwilioMessage
  attr_accessor :messaging_service_sid, :to, :from, :body, :sid, :date_created, :date_updated, :date_sent, :direction, :error_code, :error_message, :status

  def initialize(params)
    @messaging_service_sid = params[:messaging_service_sid]
    @to = params[:to]
    @body = params[:body]
    @sid = params[:sid]
    @date_updated = params[:date_updated]
    @date_created = params[:date_created]
    @direction = params[:direction]
    @date_sent = params[:date_sent]
    @error_code = params[:error_code]
    @error_message = params[:error_message]
    @status = params[:status]
  end
end

class FakeTwilioLookups
  def phone_numbers(_numbers)
    FakeTwilioPhoneNumberContext.new
  end
end

class FakeTwilioPhoneNumberContext
  def fetch(_args = nil)
    FakeTwilioPhoneNumberInstance.new
  end
end

class FakeTwilioPhoneNumberInstance
  def phone_number
  end

  def carrier
    {
        'type' => 'mobile',
    }
  end
end

class FakeTwilioRestError < Twilio::REST::RestError
  attr_reader :code
  def initialize(code: nil)
    @code = code
  end
end
