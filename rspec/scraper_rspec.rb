require_relative "../scraper"
require "./spec_helper.rb"

describe "Scraper" do
  
  before :each do
    @scrapy = Scraper.new
  end
  
  it "should create a scraper object" do
    @scrapy.should_not == nil
  end
  
  describe "get page method" do
    it "should take in a url" do
      page = @scrapy.get_page('http://sfbay.craigslist.org/sby/apa/2855410241.html')
      page.should be_an_instance_of Nokogiri::HTML::Document 
    end
  end
  
  describe "find links method" do
    
    it "saves found links in array" do
      @scrapy.links.should == []
      @scrapy.find_links(@scrapy.get_page('http://sfbay.craigslist.org/apa/'))
      @scrapy.links.should_not == []
      @scrapy.links[1+rand(25)].should match /http:\/\/\S+.html/
    end
    
  end
  it "should have a find emails method"
  it "should have a mail method"
end