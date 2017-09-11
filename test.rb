require 'ruby-jmeter'

BASE_URI = 'http://centricconsulting.azurewebsites.net'.freeze

class BasePage
  def initialize(dsl)
    @dsl = dsl
  end

  private

  def method_missing method, *args, &block
    @dsl.__send__ method, *args, &block
  end
end

class LandingPage < BasePage
  def visit
    get name: "#{self.class}::#{__method__}", url: BASE_URI do
    end
  end

  def test_auto_complete(term = '${searchterm}')
    get name: "#{self.class}::#{__method__}", url: "#{BASE_URI}/catalog/searchtermautocomplete",
          always_encode: true,
          fill_in: {'term' => term} do
    end
  end

  def test_search(term = '${searchterm}')
    get name: "#{self.class}::#{__method__}", url: "#{BASE_URI}/search",
        always_encode: true,
        fill_in: {'q' => term} do
    end
  end

  def open_product_page(product = '${product_slug}')
    get name: "#{self.class}::#{__method__}", url: "#{BASE_URI}/#{product}"
  end
end


test do
  csv_data_set_config filename: 'searchterms.csv',
                      variableNames: 'searchterm'

  csv_data_set_config filename: 'products.csv',
                      variableNames: 'product_slug'
  threads count: 10 do

    header [
               {name: 'User-Agent', value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36'},
               {name: 'Accept', value: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'}
           ]

    page = LandingPage.new(self)
    page.visit
    page.test_auto_complete
    page.open_product_page
  end
end.jmx