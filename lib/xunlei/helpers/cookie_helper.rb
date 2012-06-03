module Xunlei
  module Helper
    module CookieHelper
      def format_cookie(cookie)
        expires = cookie[:expires] ? cookie[:expires].strftime("%s") : "0"
        "#{cookie[:domain]}\tTRUE\t#{cookie[:path]}\tFALSE\t#{expires}\t#{cookie[:name]}\t#{cookie[:value]}\n"
      end
    end
  end
end
