require 'listener'

describe Listener do
  before(:all) do
    @listener = Listener.new(%w(rb erb haml))
  end
  
  it "should be timestamped" do
    @listener.last_check.should be_instance_of(Time)
  end
  
  it "should not ignore regular directories" do
    @listener.ignore_path?('/project/foo/bar').should_not be
  end
  
  it "should ignore .git directories" do
    @listener.ignore_path?('/project/.git/index').should be
  end
  
  it "should ignore dotfiles" do
    @listener.ignore_file?('/project/.foo').should be
  end
  
  it "should not ignore files without extension" do
    @listener.ignore_file?('/project/foo.rb').should_not be
  end
  
  it "should ignore files without extension" do
    @listener.ignore_file?('/project/foo').should be
  end
  
  it "should ignore files with extensions that don't match those specified" do
    @listener.ignore_file?('/project/foo.bar').should be
  end
end