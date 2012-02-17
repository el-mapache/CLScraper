require 'net/http'
require 'nokogiri'
require 'open-uri'

class Scraper
  attr_reader :links
  
  def initialize
    @links = []
  end
  
  def get_page url
    page = Nokogiri::HTML(open(url))
  end
  
  def find_links
  
  end
  
end

