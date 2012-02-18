require_relative "../scraper"
require "./spec_helper.rb"

describe "Scraper" do
  
  before :each do
    @scrapy = Scraper.new 'http://sfbay.craigslist.org/search/apa?query=&srchType=A&minAsk=500&maxAsk=520&bedrooms='
  end
  
  it "should create a scraper object" do
    @scrapy.should_not == nil
  end

  
  describe "#get_page method" do
    it "should fetch a webpage for Nokogiri to parse" do
      page = @scrapy.get_page('http://sfbay.craigslist.org/sby/apa/2855410241.html')
      page.should be_an_instance_of Nokogiri::HTML::Document 
    end
  end
  
  describe "#find_links method" do
    it "saves found links in array" do
      @scrapy.find_links(@scrapy.get_page('http://sfbay.craigslist.org/apa/'))
      @scrapy.links.should_not == []
      @scrapy.links[1+rand(25)].should match /http:\/\/\S+.html/
    end
    
    it "checks links against existing entries"
    
  end
  
  describe "the return values of #parse_page " do

     it "returns page information" do
       url = 'http://sfbay.craigslist.org/nby/apa/2853132006.html'
       title = "$1450 / 2br - Clean, Cute Older House in Wonderful Shape in Bodega (not Bodega Bay)  (sebastopol)"
       date = "2012-02-17, 12:40PM PST"
       id = 2853132006
       email = 'mztb8-2853132006@hous.craigslist.org'

       page = @scrapy.get_page(url)
       return_hash = @scrapy.parse_page(page)
       
       return_hash['title'].should == title
       return_hash['date'].should == date
       return_hash['id'].should == id
       return_hash['email'].should == email 
    end
  end
  
  describe "#dispatch" do
    it "should open an external email" do
      file = File.open '../email_template.txt', 'r'
      file.should be_an_instance_of File
    end
  end

  it "should have a find emails method"
  
  describe "#mail_with_post_attributes" do
    it "should have a mail method" do
      email_body = @scrapy.fetch_email_template
    end
  end
  
end