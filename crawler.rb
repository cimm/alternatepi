# Checks if the Alternate webshop has any Raspberry Pi’s in stock.

require "nokogiri"
require "open-uri"

class AlternatePiMonitor
  URL = URI.parse("https://www.alternate.be/listing.xhtml?q=RASPBERRY+PI&s=default&filter_-2=true&filter_416=1703")
  #URL = URI.parse('https://www.alternate.be/listing.xhtml?q=RASPBERRY+PI&s=default&filter_416=1703')

  def run
    products = []
    page = Nokogiri::HTML(URI.open(URL))
    page.css('.productBox').each do |box|
      products << extract_product_data(box)
    end
    p products.count
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
    raw.gsub(',','.').gsub(/[^\d.]/, '').to_f
  end

  def clean_delivery_info(box)
    raw = box.css('.delivery-info').text
    !raw.strip.include? 'Niet op voorraad, geen informatie beschikbaar'
  end
end

AlternatePiMonitor.new.run
