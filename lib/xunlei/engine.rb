# encoding: utf-8
require "watir-webdriver"

module Xunlei
  class Engine
    def initialize(username, password, driver = :chrome)
      @browser = Watir::Browser.new driver
      @browser.goto "http://lixian.vip.xunlei.com"
      signin(username, password)
      wait_till_all_loaded
    end

    require "xunlei/helpers/cookie_helper"
    include ::Xunlei::Helper::CookieHelper
    def dump_cookies
      wait_till_all_loaded
      @browser.driver.manage.all_cookies.inject([]) { |all_cookies, c| all_cookies << dump_cookie(c) }
    end

    def dump_tasks
      all_files = dump_current_page
      while next_page?
        next_page!
        all_files += dump_current_page
      end
      all_files
    end

    def add_task(target_address)

      @browser.execute_script("add_task_new(0)")
      @browser.text_field(:id => 'task_url').wait_until_present
      @browser.execute_script("document.getElementById('task_url').value = '#{target_address}'")

      expire_count = 0
      sleep(2.0)
      while !(@browser.button(:id => 'down_but').enabled? && expire_count <= 5000)
        expire_count += 1
      end
      if expire_count <= 5000
        @browser.button(:id => 'down_but').when_present.click
      else
        # puts "Timed out, the button is unavailable."
      end
    end

    def stop
      @browser.close
    end

    private

    def signin(username, password)
      @browser.text_field(:id => "u").when_present.set(username)
      @browser.text_field(:id => "p_show").when_present.set(password)
      @browser.button(:id => "button_submit4reg").when_present.click
    end

    def wait_till_all_loaded
      get_task_list
    end

    def get_task_list
      @browser.div(:id => "rowbox_list").tap { |list| list.wait_until_present }
    end

    def next_page?
      @browser.li(:class => "next").present?
    end

    def next_page!
      @browser.li(:class => "next").a.click
      wait_till_all_loaded
    end

    def dump_current_page
      get_task_list.divs(:class => "rw_inter").inject([]) do |result, div|
        @current_task_id = div.parent.id.gsub(/\D+/, "")
        result += dump_task
      end
    end

    def bt_task?
      task_div.div(:class => "w03img").img.src == "http://cloud.vip.xunlei.com/160/img/icon_type/tpimg_bt.png"
    end

    def expand_task_div!
      task_div.click
      task_div.a(:class => "rwbtn ic_redownloca").wait_until_present
    end

    def wait_till_task_loaded
      task_div.wait_until_present
      @browser.execute_script("document.getElementById('#{task_div.parent.id}').scrollIntoView()")
    end

    def task_div
      @browser.div(:id => "tr_c#{@current_task_id}").div(:class => "rw_inter")
    end

    def dump_task
      return [] unless task_finished?

      expand_task_div!

      if bt_task?
        dump_bt_task
      else
        dump_normal_task
      end
    end

    def task_finished?
      wait_till_task_loaded
      task_div.em(:class => "loadnum").text == "100%"
    end

    def dump_normal_task
      [{
        :name => task_div.span(:class => "namelink").as.first.text.gsub(/'|\\/,""),
        :url => task_div.input(:id => "dl_url" + @current_task_id).value,
        :size => task_div.span(:id => "size#{@current_task_id}").text
      }]
    end

    def dump_bt_task
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
          if folder_list.span(:class => "namelink").span.title != @browser.div(:id => "rwbox_bt_list").span(:class => "namelink").span.title
            break
          end
        rescue
          break
        end while next_page_exists && Time.now - time0 < 5
        sleep 1
      end while next_page_exists

      go_back_from_bt_task!

      task_files
    end

    def go_back_from_bt_task!
      @browser.div(:id => "view_bt_list_nav").tap do |back_div|
        back_div.wait_until_present
        back_div.li(:class => "main_link main_linksub").a(:class => "btn_m").click
      end
    end
  end
end
