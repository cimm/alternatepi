require 'net/https'

class Notifier
  PROWL_URL = URI('https://api.prowlapp.com/publicapi/add')

  def initialize(message:, title:, key: nil)
    @message = message
    @title = title
    @key = key
  end

  def send(channel: :stdout)
    case channel
      when :prowl then to_prowl
      else to_stdout
    end
  end

  def to_prowl
    Net::HTTP.post_form(PROWL_URL,
                        apikey: @key,
                        application: @title,
                        description: @message)
  end

  def to_stdout
    puts '-- ' + @title
    puts @message
  end
end
