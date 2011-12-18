require "watir-webdriver"
require "Nokogiri"
require "uri"

module Xunlei
  class Search
    def initialize(driver = :chrome)
      @browser = Watir::Browser.new driver
    end
    
    def google(keywords, options)
      do_google(keywords, options, "http://www.google.com/search?q=", 10)
    end
    
    def google_simplecd(keywords, options)
      do_google(keywords, options, "http://www.google.com/search?q=site:simplecd.org+", 1)
    end
    
  private
  
    def do_google(keywords, options, prefix, limit)
      q = [keywords, options.with, "ed2k"].flatten.join("+")
      q += "+-" + options.without unless options.without.nil?
      
      @browser.goto "#{prefix}#{q}"
      
      @browser.div(:id => "ires").wait_until_present
      
      page_links = []
      @browser.lis(:class => "g").each { |li| page_links << li.as.first.href }
      
      ed2k_links = []
      
      page_links.each do |page_link|
        @browser.goto page_link
        doc = Nokogiri::HTML(@browser.html)
        doc.css("a").each do |link|
          next if link['href'].nil?
          # href = URI.escape(link['href'])
          href = link['href']
          if href =~ /ed2k:|magnet:/ && !ed2k_links.include?(href)
            puts href
            ed2k_links << href
          end
        end
        
        limit -= 1
        break unless limit > 1
      end
      
      @browser.close
      
      ed2k_links
    end
  end
end
