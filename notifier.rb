require 'net/https'

class Notifier
  PROWL_URL = URI('https://api.prowlapp.com/publicapi/add')

  def initialize(message:, title:, key: nil)
    @message = message
    @title = title
    @key = key
  end

  def send
    if @key.nil?
      send_stdout
    else
      send_prowl
    end
  end

  def send_prowl
    Net::HTTP.post_form(PROWL_URL,
                        apikey: @key,
                        application: @title,
                        description: @message)
  end

  def send_stdout
    puts '-- ' + @title
    puts @message
  end
end
