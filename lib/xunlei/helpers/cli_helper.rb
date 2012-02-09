module Xunlei
  module Helper
    module CLIHelper

      def filtered?(file, options)
        return false unless options
        return true if !options.only.nil? and !(file[:name] =~ /#{options.only}/i)
        return true if !options.except.nil? and file[:name] =~ /#{options.except}/i
        false
      end

      def filter_files(files, options=nil)
        files.select{ |file| !filtered?(file, options) }.inject([], :<<)
      end
    end
  end
end