require "watir-webdriver"
require "nokogiri"

module Xunlei
  class Search
    def initialize(driver = :chrome)
      @browser = Watir::Browser.new driver
    end
    
    def google(keywords, options=nil)
#      @browser.goto "http://www.google.com/search?q=#{[keywords, options, "ed2k"].flatten.join("+")}"
		 puts "Connecting to eztv..."
		 @browser.goto "http://eztv.it"
		 @browser.text_field(:name => 'SearchString1').when_present.set([keywords].flatten.join(" "))
#@browser.execute_script("return search_submit_form( 'search_submit' );")

		 @browser.form(:id => 'search').when_present.submit
		 puts "Submitting query..."
#puts @browser.as(:class => 'magnet').each do |a|
#puts a.href
#end
		 doc = Nokogiri::HTML(@browser.html)
		 okay = false
		 $target_url = ""
		 puts "Analyzing HTML..."
		 doc.css("td").each do |td_space|
		   if !(td_space['class'] =~ /featured_links/)
				docs = Nokogiri::HTML("#{td_space}")
				docs.css("a").each do |link|
					href = link['href']
					if (href =~ /magnet:/) && (options == nil || (href =~ /#{options}/i))
						puts "Plausible link found:"
						puts href
						okay = true
						$target_url = href
					end
					break unless !okay
				end
			end
			break unless !okay
		 end
		 puts "Finished analyzing HTML"
		 @browser.close
		 if(okay && agree("Would you like to add it to your Xunlei tasklist?\n(yes or no)"))
			puts "Okay, creating task..."
			cmd = "xunlei_with_proxy add \"#{$target_url}\""
		   system(cmd)	
		 else
			puts "Exiting..."
		 end

#      @browser.div(:id => "ires").wait_until_present
      
#      page_links = []
#      @browser.lis(:class => "g").each { |li| page_links << li.as.first.href }
      
#      ed2k_links = []
#      page_links.each do |page_link|
#        @browser.goto page_link
#        doc = Nokogiri::HTML(@browser.html)
#        doc.css("a").each do |link|
#          href = link['href']
#          if href =~ /ed2k:|magnet:/ && !ed2k_links.include?(href)
#            puts href
#            ed2k_links << href
#          end
#        end
#      end
#      
#      @browser.close
#      
#      ed2k_links
    end
  end
end
