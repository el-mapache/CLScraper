require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pony'
require 'yaml'

class Scraper
  attr_reader :links
  
  # push back on client! we don't need no yml. a url would suffice.
  def initialize yml_file
    
    @links = []
    @posts_already_mailed = []
    
    search_url = load_yaml yml_file
    page = get_page search_url  
    find_links page
  end
  
  def load_yaml yml_file
    loaded_yml = YAML.load_file yml_file
    loaded_yml['URL_to_search']
  end
  
  def get_page url
    Nokogiri::HTML(open(url))
  end
  
  def find_links page
    page.css('p a').each do |paragraph|
      @links << paragraph['href']
    end
  end
  
  def parse_page page
    post_attributes = {}
    
    title = page.css('h2')
    email = page/"//a[starts-with(@href,'mailto')]"
    
    post_attributes['title']   =     title.inner_text
    post_attributes['email']   =     email.inner_text
    post_attributes['date']    =     page.text.match(/Date:\ [0-9]{4,4}\-[0-9]{2,2}\-[0-9]{2,2},\s+[0-9]+\:[0-9]{2,2}[A-Z]+\s+[A-Z]+/).to_s[6..-1]
    post_attributes['id']      =     page.text.match(/PostingID:\s[0-9]+/).to_s[10..-1].to_i
    
    post_attributes
  end
  
  def mail_with_post_attributes post_attributes
    unless @posts_already_mailed.include?(post_attributes['id'])
      body = fetch_email_template
      begin
        @posts_already_mailed << post_attributes['id']
        Pony.mail(:to  => 'adam.biagianti@gmail.com', :via => :smtp, :via_options => {
            :address => 'smtp.gmail.com',
            :port => '587',
            :enable_starttls_auto => true,
            :user_name => 'ryan.adam.scraper@gmail.com',
            :password => 'passworD',
            :authentication => :plain,
            :domain => "HELO",
        },
        :subject => "Re: #{post_attributes['title']}", :body => "#{body}   \n\n\n#{post_attributes['email']}")
      rescue  => msg
        puts "#{msg}"
      end
    end
  end
  
  def fetch_email_template
    template = ''
    email_template = File.open 'email_template.txt', 'r'
    while line = email_template.gets
      template << line + "\n"
    end
    template
  end
  
  def dispatch
    @links.each do |link|
        page = get_page(link)
        pages_attributes = parse_page(page)
        mail_with_post_attributes(pages_attributes)
      end
  end
  
end

s = Scraper.new 'parameters.yml'
#s.dispatch
