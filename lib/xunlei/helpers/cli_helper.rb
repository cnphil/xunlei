require "yaml"

module Xunlei
  module Helper
    module CLIHelper
      require "xunlei/configurator"
      include ::Xunlei::Config

      def filtered?(file, options)
        return false unless options
        return true if !options.only.nil? and !(file[:name] =~ /#{options.only}/i)
        return true if !options.except.nil? and file[:name] =~ /#{options.except}/i
        false
      end

      def filter_files(files, options=nil)
        files.select{ |file| !filtered?(file, options) }.inject([], :<<)
      end

      def total_size(file_sizes)
        file_sizes.inject(0) do |total_megabytes, file_size|
          if file_size =~ /G/i
            total_megabytes + 1000 * file_size.to_f
          elsif file_size =~ /M/i
            total_megabytes + file_size.to_f
          else
            total_megabytes + 1
          end
        end
      end

      def show_files(files)
        files.each do |file|
          puts "#{file[:size]}\t#{file[:name]}"
        end

        puts
        puts "Total: #{files.size} files, #{total_size(files.map { |file| file[:size] })} MB (estimated)"
      end

      def mark_as_downloaded(task)
        puts "#{task[:name]} successfully downloaded."

        downloaded = all_downloaded_tasks
        downloaded << task[:name]
        File.open(xunlei_downloaded_tasks_path, "w") do |file|
          file.write(downloaded.to_yaml)
        end

        all_tasks = YAML.load_file(xunlei_tasks_path)
        all_tasks.delete(task)
        File.open(xunlei_tasks_path, "w") do |file|
          file.write(all_tasks.to_yaml)
        end
      end

      def all_downloaded_tasks
        system("touch #{xunlei_downloaded_tasks_path}") # touch it in case it's non-existent

        YAML.load_file(xunlei_downloaded_tasks_path) || []
      end

      def ask_for_credentials
        puts "#{xunlei_credential_file_path} not exists. Now creating one."
        puts "*** WARNING: your USERNAME and PASSWORD will be stored as PLAINTEXT at #{xunlei_credential_file_path} ***"

        username = ask("Username: ")
        password = ask("Password: ") { |q| q.echo = "*" }
        File.open(xunlei_credential_file_path, "w") do |file|
          file.write({ :username => username, :password => password }.to_yaml)
        end

        puts "#{xunlei_credential_file_path} successfully created."
      end

      def check_for_credentials
        ask_for_credentials unless credential_file_exists?
      end

      def create_xunlei_folder
        Dir.mkdir(xunlei_folder_path)
      end

      def xunlei_folder_exists?
        Dir.exists?(xunlei_folder_path)
      end

      def credential_file_exists?
        File.exists?(xunlei_credential_file_path)
      end

      def check_for_chromedriver
        unless system("which chromedriver > /dev/null 2>&1")
          puts "chromedriver not found in your PATH"
          if agree("Would you like me to try download it for you? (yes or no)")
            if system("wget 'http://chromium.googlecode.com/files/chromedriver_mac_16.0.902.0.zip' -O #{chromedriver_zip_name}")
              if system("unzip #{chromedriver_zip_name}")
                puts "moving chromedriver to /usr/local/bin ..."
                system("mv -v chromedriver /usr/local/bin")

                puts "deleting temporary files..."
                system("rm -v #{chromedriver_zip_name}")
              else
                puts "`unzip` not found in your PATH. Try manually unzip #{chromedriver_zip_name} and move it to /usr/local/bin"
                exit
              end
            end
          else
            puts "OK. You can download it manually here: http://code.google.com/p/chromium/downloads"
            exit
          end
        end
      end
    end

    def check_for_config_files
      create_xunlei_folder unless xunlei_folder_exists?
      check_for_credentials
    end
  end
end