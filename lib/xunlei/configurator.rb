module Xunlei
  module Configurator

    def xunlei_folder_name
      "~/.xunlei"
    end

    def xunlei_folder_path
      File.expand_path(xunlei_folder_name)
    end

    def xunlei_cookies_path
      File.join(xunlei_folder_path, "cookies.txt")
    end

    def xunlei_tasks_path
      File.join(xunlei_folder_path, "all_tasks.yml")
    end

    def xunlei_credential_file_path
      File.join(xunlei_folder_path, "credentials.yml")
    end

    def xunlei_downloaded_tasks_path
      File.join(xunlei_folder_path, "downloaded.yml")
    end

    def chromedriver_zip_name
      "chromedriver_mac.zip"
    end
  end

  Config = Configurator
end