require "spec_helper"

describe Xunlei::Search do
  before(:each) do
    $stdout.stub(:puts)
  end
  
  describe "Google" do
    it "should find some ed2k links" do
      search = Xunlei::Search.new
      links = search.google("Repulsion", "720p")
      
      links.should_not be_empty
    end
  end
end