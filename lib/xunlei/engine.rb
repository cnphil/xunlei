require "watir-webdriver"

module Xunlei
  class Engine
    def initialize(username, password, driver = :chrome)
      @browser = Watir::Browser.new driver
      @browser.goto "http://lixian.vip.xunlei.com"

      @browser.text_field(:id => "u").when_present.set(username)
      @browser.text_field(:id => "p_show").when_present.set(password)
      @browser.button(:id => "button_submit4reg").when_present.click
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
    
    def dump_tasks
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
        task_div.a(:class => "rwbtn ic_down").wait_until_present

        if task_div.a(:class => "rwbtn ic_open").present?
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
      { :name => normal_task_a.text, :url => normal_task_input.value }
    end
    
    def process_bt_task(task_div)
      task_files = []
      task_div.a(:class => "rwbtn ic_open").when_present.click

      folder_list = @browser.div(:id => "rwbox_bt_list")
      folder_list.wait_until_present
      
      folder_list.as(:name => "bturls").each do |a|
        task_files << { :name => a.text, :url => a.href }
      end

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