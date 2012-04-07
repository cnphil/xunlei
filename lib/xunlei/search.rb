require "Nokogiri"
require "uri"
require "open-uri"

module Xunlei
  class Search
    def initialize(driver = :chrome)
    end
    
    def google(keywords, options)
      do_google(keywords, options, "http://www.google.com/search?q=", 10)
    end
    
    def google_simplecd(keywords, options)
      do_google(keywords, options, "http://www.google.com/search?q=site:simplecd.org+", 1)
    end
    
    def add_page(page_url, options)
      doc = Nokogiri::HTML(open(page_url) { |page| page.read })
      links = []
      
      doc.css("a").select do |a|
        !a['href'].nil? && a['href'] =~ /ed2k:|magnet:/
      end.map do |a|
        a['href']
      end.uniq.each do |link|
        if !options.only.nil?
          links << link if link =~ /#{options.only}/i
        elsif !options.except.nil?
          links << link unless link =~ /#{options.except}/i
        else
          links << link
        end
      end
      links.each { |link| puts link }
      links
    end
    
  private
  
    def do_google(keywords, options, prefix, limit)
      q = [keywords, options.with, "ed2k"].flatten.join("+")
      q += "+-" + options.without unless options.without.nil?
      
      search_result = Nokogiri::HTML(open("#{prefix}#{q}") { |page| page.read })
      page_links = search_result.css(".g h3 a").map { |a| "http://www.google.com" + a['href'] }[0, limit]
      
      ed2k_links = []
      
      page_links.each do |page_link|
        doc = Nokogiri::HTML(open(page_link) { |page| page.read })
        ed2k_links += doc.css("a").select do |a|
          !a['href'].nil? && a['href'] =~ /ed2k:|magnet:/
        end.map do |a|
          a['href'].tap { |a| puts a }
        end.uniq
      end
      
      ed2k_links
    end
  end
end
