require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Hoe::Git::Changelog do
  before(:all) do
    fixture=File.expand_path(File.dirname(__FILE__)+"/fixtures/log.txt")
    @log_text=File.read(fixture)
  end
  it "should contains correct number of changes per type" do
    io=""
    cl=Hoe::Git::Changelog.new(@log_text,{:io=>io,:log_author=>false})
    cl.process
    cl.changes[:major].size.should eq 2
    cl.changes[:minor].size.should eq 2
    cl.changes[:bug].size.should eq 1
    cl.changes[:unknown].size.should eq 2
  end
  it "should return correct general output without outputs" do
    io=""
    cl=Hoe::Git::Changelog.new(@log_text,{:io=>io,:log_author=>false, :version=>"VVV", :now=>"DD-MM-YYYY"})
    cl.process
    io.should match /^\=\=\=\sVVV\s\/\sDD-MM-YYYY\s*$^\s*$^\s*\*\s+2\smajor.+?\n+(\s+\*\sMajor\s\d{1,1}\n){2,2}\n\*\s+2\sminor.+?\n+(\s+\*\sMinor\s\d{1,1}\n){2,2}\n\*\s+1\sbug.+?\n+(\s+\*\sBug\s*\n)\*\s+2\sunknowns/xm
  end
  it "should return correct general output with outputs" do
    io=""
    cl=Hoe::Git::Changelog.new(@log_text,{:io=>io,:log_author=>true})
    cl.process
    
    io.should match /Major \d{1,1} \[Author 1\].+multiline \[Author 2\]+/m
  end
  
end
