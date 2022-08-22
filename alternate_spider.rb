require 'nokogiri'
require 'open-uri'
require_relative './notifier.rb'

class AlternateSpider
  LISTING_URL = 'https://www.alternate.be/listing.xhtml'
  NO_STOCK_MESSAGE = 'Niet op voorraad, geen informatie beschikbaar'
  DIGITS_REGEX = /[^\d.]/

  attr_accessor :results

  def initialize
    @results = []
  end

  def crawl(query:, type: nil)
    url = build_url(query: query, type: type)
    page = Nokogiri::HTML(URI.open(url))
    page.css('.productBox').each do |box|
      @results << extract_product_data(box)
    end
  end

  def available?
    @results.count{ |r| r[:available] == true } > 0
  end

  def extract_product_data(box)
    data = {}
    data[:name] = clean_name(box)
    data[:price] = clean_name(box)
    data[:available] = clean_delivery_info(box)
    data
  end

  def clean_name(box)
    box.css('.product-name').text.squeeze(' ')
  end

  def clean_price(box)
    raw = box.css('.price').text
    raw.gsub(',','.').gsub(DIGITS_REGEX, '').to_f
  end

  def clean_delivery_info(box)
    raw = box.css('.delivery-info').text
    !raw.strip.include? NO_STOCK_MESSAGE
  end

  def build_url(query:, type: nil)
    fragments = {}
    fragments['q'] = query
    #fragments['filter_-2'] = true # filter search for available products only
    fragments['filter_416'] = type unless type.nil?
    URI.parse(LISTING_URL + '?' + URI.encode_www_form(fragments))
  end
end

alternate = AlternateSpider.new
alternate.crawl(query: 'RASPBERRY PI', type: 1703)
if !alternate.available?
  message = 'New Pi’s available!'
  key = ARGV[0]
  Notifier.new(message: message, title: 'Alternate', key: key).send
end
