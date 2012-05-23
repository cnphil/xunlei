require "spec_helper"

module Xunlei
  module Helper
    describe CookieHelper do
      let(:helper) { Class.new { include CookieHelper }.new }

      describe "dump_cookie" do
        it "should dump_cookie" do
          expected = ".vip.xunlei.com\tTRUE\t/\tFALSE\t0\tlx_referfrom\t\n"
          cookie_hash = {
            :name => "lx_referfrom",
            :value => "",
            :path => "/",
            :domain => ".vip.xunlei.com",
            :expires => nil,
            :secure => false
          }

          helper.dump_cookie(cookie_hash).should == expected
        end
      end
    end
  end
end
