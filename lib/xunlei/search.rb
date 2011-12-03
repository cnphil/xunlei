require "watir-webdriver"
require "Nokogiri"
require "uri"

module Xunlei
  class Search
    def initialize(driver = :chrome)
      @browser = Watir::Browser.new driver
    end
    
    def google(keywords, options)
      q = [keywords, options.with, "ed2k"].flatten.join("+")
      q += "+-" + options.without unless options.without.nil?
      
      @browser.goto "http://www.google.com/search?q=#{q}"
      
      @browser.div(:id => "ires").wait_until_present
      
      page_links = []
      @browser.lis(:class => "g").each { |li| page_links << li.as.first.href }
      
      ed2k_links = []
      page_links.each do |page_link|
        @browser.goto page_link
        doc = Nokogiri::HTML(@browser.html)
        doc.css("a").each do |link|
          next if link['href'].nil?
          href = URI.escape(link['href'])
          if href =~ /ed2k:|magnet:/ && !ed2k_links.include?(href)
            puts href
            ed2k_links << href
          end
        end
      end
      
      @browser.close
      
      ed2k_links
    end
  end
end
