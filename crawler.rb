require "open-uri"
require "rexml/document"

class Crawler
  include REXML

  #URL = URI("https://www.alternate.be/listing.xhtml?q=RASPBERRY+PI&s=default&filter_-2=true&filter_416=1703")
  URL = URI('https://www.alternate.be/listing.xhtml?q=RASPBERRY+PI&s=default&filter_416=1703')
  REMOVE_TAGS_REGEX = /<("[^"]*"|'[^']*'|[^'">])*>/

  def fetch_and_parse
    URI.open(URL).each_line do |line|
      data[:name] = parse_name_line(line) if name_line?(line)
      data[:price] = parse_price_line(line) if price_line?(line)
      data[:stock] = parse_stock_line(line) if stock_line?(line)
      p data unless data.keys.empty?
    end
  end

  def name_line?(line)
    line.strip.start_with?('<div class="product-name')
  end

  def parse_name_line(line)
    remove_html(line).strip
  end

  def price_line?(line)
    line.strip.start_with?('<div class="col-auto pl-0"><span class="price')
  end

  def parse_price_line(line)
    remove_html(line).strip
  end

  def stock_line?(line)
    line.strip.start_with?('<div class="col-auto delivery-info')
  end

  def parse_stock_line(line)
    text = remove_html(line)
    !text.strip.start_with?('Niet op voorraad, geen informatie beschikbaar')
  end

  def remove_html(line)
    line.gsub(REMOVE_TAGS_REGEX, '')
  end
end

Crawler.new.fetch_and_parse
