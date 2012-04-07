# encoding: utf-8
require "watir-webdriver"

module Xunlei
  class Engine
    def initialize(username, password, driver = :chrome)
      @browser = Watir::Browser.new driver
      @browser.goto "http://lixian.vip.xunlei.com"

      @browser.text_field(:id => "u").when_present.set(username)
      @browser.text_field(:id => "p_show").when_present.set(password)
      @browser.button(:id => "button_submit4reg").when_present.click

      # temp fix for stupid cloud VOD popup
      wait_until_all_loaded
      #@browser.div(:class => "p_rw_pop p_sc_pop p_yuntips").p(:class => 'p_btm_aline').as.first.when_present.click
    end

    def dump_cookies
      wait_until_all_loaded

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

      sleep 2
      begin
        all_files += process_current_page
      end while next_page

      all_files
    end

    def add_task(target_address)
      puts "Adding new task..."
      # open('|pbcopy', 'w') { |io| io << target_address }

      @browser.execute_script("add_task_new(0)")

      @browser.text_field(:id => 'task_url').wait_until_present

      # @browser.send_keys [:command, 'v']
      @browser.execute_script("document.getElementById('task_url').value = '#{target_address}'")

      puts "Task URL = \"#{target_address}\""
      expire_count = 0
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

      return false unless next_li.present?

      next_li.as.first.click

      wait_until_all_loaded
    end

    def process_current_page
      get_task_list.divs(:class => "rw_inter").inject([]) do |all_files, task_div|
        all_files += process_task(task_div)
      end
    end

    def process_task(task_div)
      task_files = []

      task_div.wait_until_present

      @browser.execute_script("document.getElementById('#{task_div.parent.id}').scrollIntoView()")

      if task_is_ready?(task_div)
        # puts "task is ready"
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
      task_id = task_div.parent.id.gsub(/\D+/, "")
      normal_task_input = task_div.input(:id => "dl_url" + task_id)
      { :name => normal_task_a.text.gsub(/'|\\/,""), :url => normal_task_input.value, :size => task_div.span(:id => "size#{task_id}").text }
    end

    def process_bt_task(task_div)
      task_files = []
      task_div.a(:class => "rwbtn ic_open").when_present.click

      next_page_exists = false
      begin
        folder_list = @browser.div(:id => "rwbox_bt_list")
        folder_list.wait_until_present

        index = 0
        folder_list.spans(:class => "namelink").each do |span|
          s = span.spans.first
          size = folder_list.input(:id => "bt_size#{index}").attribute_value('value')
          task_files << { :name => s.title, :url => s.attribute_value('href'), :size => size }
          index += 1
        end
        # to check if there is a next page
        next_bt_link = @browser.a(:title => "下一页")
        break unless next_bt_link.exists?

        next_page_exists = next_bt_link.attribute_value("class") != "a_up"
        @browser.execute_script next_bt_link.attribute_value("onclick")
        time0 = Time.new
        begin
          if folder_list.spans(:class => "namelink").first.spans.first.title != @browser.div(:id => "rwbox_bt_list").spans(:class => "namelink").first.spans.first.title
            break
          end
        rescue
          break
        end while next_page_exists && Time.now - time0 < 5
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
