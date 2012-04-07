# encoding: utf-8
require "watir-webdriver"

module Xunlei
  class Engine
    def initialize(username, password, driver = :chrome)
		puts "Connecting to Xunlei..."
      @browser = Watir::Browser.new driver
      @browser.goto "http://lixian.vip.xunlei.com"
		
		puts "Logging in..."
      @browser.text_field(:id => "u").when_present.set(username)
      @browser.text_field(:id => "p_show").when_present.set(password)
      @browser.button(:id => "button_submit4reg").when_present.click
		puts "Logged in"
		wait_until_all_loaded
		puts "All loaded."
#@browser.div(:id => "yun_tj").checkbox(:value => "").when_present.set
	 end
    
    def dump_cookies
      # wait until cookies are ready
      get_task_list
      
      cookies = []
      @browser.driver.manage.all_cookies.each do |cookie|
        domain = cookie[:domain]
        path = cookie[:path]
        expires = cookie[:expires] ? cookie[:expires].strftime("%s") : "0"
        name = cookie[:name]
        value = cookie[:value]
        cookies << "#{domain}\tTRUE\t#{path}\tFALSE\t#{expires}\t#{name}\t#{value}\n"
      end
      
      cookies
    end
   
#phil start stamp
	 def add_task(target_address)
		puts "Creating new task..."
		@browser.execute_script("javascript:add_task_new(0);")
		@browser.text_field(:id => 'task_url').when_present.set("#{target_address}")
		puts "Task URL = \"#{target_address}\""
		expire_count = 0;
		sleep(2.0)
		while !(@browser.button(:id => 'down_but').enabled? && expire_count <= 5000)
			expire_count += 1
		end
		if expire_count <= 5000
			print "Submitting... "
			@browser.button(:id => 'down_but').when_present.click
			puts "Done."
		else
			puts "Timed out, the button is unavailable."
		end
	 end

#phil end stamp

    def dump_tasks
		@browser.div(:id => 'flash_link').when_present.click
		wait_until_all_loaded
      all_files = []
      
      begin
        all_files += process_current_page
      end while next_page
      
      all_files
    end
    
    def stop
      @browser.close
    end
    
  private  
    
    def wait_until_all_loaded
      get_task_list
    end
    
    def get_task_list
      task_list = @browser.div(:id => "rowbox_list")
      task_list.wait_until_present
      task_list
    end
    
    def next_page
      next_li = @browser.li(:class => "next")
      if next_li.present?
        next_li.as.first.click
        true
      else
        false
      end
    end
    
    def process_current_page
      task_list = get_task_list
      
      all_files = []

      task_list.divs(:class => "rw_list").each do |task_div|
        all_files += process_task(task_div)
      end

      all_files
    end
    
    def process_task(task_div)
      task_files = []
      
      task_div.wait_until_present

      if task_is_ready?(task_div)  
        task_div.click
        task_div.a(:class => "rwbtn ic_redownloca").wait_until_present

        if task_div.div(:class => "w03img").imgs.first.src == "http://cloud.vip.xunlei.com/160/img/icon_type/tpimg_bt.png"
          task_files += process_bt_task(task_div)
        else
          task_files << process_normal_task(task_div)
        end
      else
        # still downloading
      end
      
      task_files
    end
    
    def task_is_ready?(task_div)
      task_div.em(:class => "loadnum").text == "100%"
    end
    
    def process_normal_task(task_div)
      normal_task_a = task_div.span(:class => "namelink").as.first
      normal_task_input = task_div.input(:id => "dl_url" + task_div.id.gsub(/\D+/, ""))
		{ :name => normal_task_a.text.gsub(/'|\\/,""), :url => normal_task_input.value }
    end
    
    def process_bt_task(task_div)
      task_files = []
      task_div.a(:class => "rwbtn ic_open").when_present.click

		next_page_exists = false
		begin
			puts "hello world"
			folder_list = @browser.div(:id => "rwbox_bt_list")
			folder_list.wait_until_present
		
#random_name = folder_list.spans(:class => "namelink").first.spans.first.title
			folder_list.spans(:class => "namelink").each do |span|
				s = span.spans.first
#puts "Got " + s.title
				task_files << { :name => s.title, :url => s.attribute_value('href') }.tap {|s| p s}
			end
			puts "trying to retrieve link data"
			next_bt_link = @browser.a(:title => "下一页")
			if(!next_bt_link.exists?)
				break
			end
			next_page_exists = next_bt_link.attribute_value("class") != "a_up"
			@browser.execute_script(next_bt_link.attribute_value("onclick"))
			time0 = Time.new
			begin
				if(folder_list.spans(:class => "namelink").first.spans.first.title != @browser.div(:id => "rwbox_bt_list").spans(:class => "namelink").first.spans.first.title)
					puts "diff breaked"
					break
				end
			rescue
				puts "rescued"
				break
			end while(next_page_exists && Time.now - time0 < 5)
			sleep 1

		end while next_page_exists

      go_back_from_bt_task
      
      task_files
    end
    
    def go_back_from_bt_task
      back_div = @browser.div(:id => "view_bt_list_nav")
      back_div.wait_until_present
      back_div.lis(:class => "main_link main_linksub").first.a(:class => "btn_m").click
    end
  end
end
