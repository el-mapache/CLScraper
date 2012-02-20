#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pony'
require 'yaml'

CONFIGS = YAML.load_file Dir.pwd + '/Documents/Scraper-7/config/scrape_configs.yml'

class Scraper    
  def initialize url
    @url = url
    @links = []
  end
  
  def get_page page_url
    Nokogiri::HTML open page_url
  end
  
  def find_links page, *args
    selectors =  args.join ' '
    page.css(selectors).each do |element|
      @links << element['href']
    end
  end  
end

class CLScraper < Scraper
  def initialize url
    @ids_file = File.open Dir.pwd + '/Documents/Scraper-7/posting_ids.txt', 'r'
    @previously_scraped_posts = {}
    super
    
    page = get_page @url
    find_links page, 'p', 'a'
    populate_id_match
  end
  
  def parse_page page
    post_attributes = {}
    
    title = page.css 'h2' 
    email = page/"//a[starts-with(@href,'mailto')]"
    
    post_attributes['title']   =     title.inner_text
    post_attributes['email']   =     email.inner_text
    post_attributes['date']    =     page.text.match(/Date:\ [0-9]{4,4}\-[0-9]{2,2}\-[0-9]{2,2},\s+[0-9]+\:[0-9]{2,2}[A-Z]+\s+[A-Z]+/).to_s[6..-1]
    post_attributes['id']      =     page.text.match(/PostingID:\s[0-9]+/).to_s[11..-1]
    
    puts post_attributes['id']
    @ids_file.write(post_attributes['id'].to_s + "\n") if !@previously_scraped_posts[post_attributes['id']]
    
    post_attributes
  end
  
  def populate_id_match
    while line = @ids_file.gets
      @previously_scraped_posts[line.chomp] = true
    end
      @ids_file.close
  end
  
  def dispatcher
    @ids_file = File.open Dir.pwd + '/Documents/Scraper-7/posting_ids.txt', 'a'
    email_handler = EmailHandler.new @previously_scraped_posts
    @links.each do |link|
        page = get_page link 
        page_attributes = parse_page page 
        email_handler.mailer page_attributes 
      end
    @ids_file.close
  end
end

class EmailHandler
  def initialize previously_scraped_posts
    @previously_scraped_posts = previously_scraped_posts
  end
  
  def fetch_email_template
    template = ''
    email_template = File.open Dir.pwd + '/Documents/Scraper-7/email_template.txt', 'r'
    while line = email_template.gets
      template << line + "\n"
    end
    email_template.close
    template
  end
  
  def mailer post_attributes
    unless @previously_scraped_posts[post_attributes['id']]
      body = fetch_email_template
      begin
        @previously_scraped_posts[post_attributes['id']]
        Pony.mail(:to  => CONFIGS['EmailTo'], :via => :smtp, :via_options => {
                  :address => 'smtp.gmail.com',
                  :port => '587',
                  :enable_starttls_auto => true,
                  :user_name => CONFIGS['username'],
                  :password => CONFIGS['password'],
                  :authentication => :plain,
                  :domain => "HELO",
        },
        :subject => "Re: #{post_attributes['title']}", :body => "#{body}   \n\n\n#{post_attributes['email']}")
        puts "message sent"
      rescue  => msg
        puts "#{msg}"
      end
    end
  end
end

s = CLScraper.new CONFIGS['URL']
s.dispatcher