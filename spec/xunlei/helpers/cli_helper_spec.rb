require "spec_helper"
require "ostruct"

describe Xunlei::Helper::CLIHelper do
  before(:each) do
    @main = Class.new
    @main.class_eval { extend Xunlei::Helper::CLIHelper }

    @options_only = OpenStruct.new :only => "matrix"
    @options_except = OpenStruct.new :except => "matrix"
    @options_nil = OpenStruct.new
  end

  describe "filtered?" do
    before(:each) do
      @file = "MatRiX"
    end

    it "should have a filtered? method" do
      @main.should respond_to(:filtered?)
    end

    it "should filter correctly" do
      @main.filtered?(@file, nil).should be_false
      @main.filtered?(@file, @options_only).should be_false
      @main.filtered?(@file, @options_except).should be_true
      @main.filtered?(@file, @options_nil).should be_false
    end
  end

  describe "filter_files" do
    before(:each) do
      @files = [{:name => "LOTR"}, {:name => "MatRix"}, {:name => "Bourne"}]
    end
    it "should have a filter_files method" do
      @main.should respond_to(:filter_files)
    end

    it "should filter correctly" do
      @main.filter_files(@files, @options_only).count.should == 1
      @main.filter_files(@files, @options_except).count.should == 2
      @main.filter_files(@files, @options_nil).count.should == 3
      @main.filter_files(@files, nil).count.should == 3
    end
  end

  describe "total_size" do
    it "should have a total_size method" do
      @main.should respond_to(:total_size)
    end

    it "should calculate total size correctly" do
      @main.total_size(%w{1.1G 300M 512K}).should == 1.1 * 1000 + 300 + 1
    end
  end
end