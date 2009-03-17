require 'runner'

class ::Runner
  def self.run_command(cmd)
    # never shell out in tests
    cmd
  end
end

describe ::Runner do
  
  before(:all) do
    @runner = ::Runner
  end
  
  describe "setup" do
    before(:each) do
      Dir.stub!(:pwd).and_return('/my/path')
      @runner.stub!(:puts)
      Inspector.stub!(:new)
      Interactor.stub!(:new).and_return(mock('Interactor').as_null_object)
      Listener.stub!(:new).and_return(mock('Listener').as_null_object)
    end
    
    def setup
      @runner.load
    end
    
    it "should initialize Inspector" do
      Inspector.should_receive(:new).with('/my/path')
      setup
    end
  
    it "should start Interactor" do
      interactor = mock('Interactor')
      interactor.should_receive(:wait_for_enter_key).with(instance_of(String), 3)
      interactor.should_receive(:start_termination_handler)
      Interactor.should_receive(:new).and_return(interactor)
      setup
    end
  
    it "should run all specs if Interactor isn't interrupted" do
      interactor = mock('Interactor', :start_termination_handler => nil)
      interactor.should_receive(:wait_for_enter_key).and_return(nil)
      Interactor.should_receive(:new).and_return(interactor)
      @runner.should_receive(:run_spec_command).with('spec')
      setup
    end
  
    it "should skip running all specs if Interactor is interrupted" do
      interactor = mock('Interactor', :start_termination_handler => nil)
      interactor.should_receive(:wait_for_enter_key).and_return(true)
      Interactor.should_receive(:new).and_return(interactor)
      @runner.should_not_receive(:run_spec_command)
      setup
    end
  
    it "should run Listener" do
      listener = mock('Listener')
      listener.should_receive(:run).with('/my/path')
      Listener.should_receive(:new).with(instance_of(Array)).and_return(listener)
      setup
    end
  
    it "should output 'watching' message on start" do
      @runner.should_receive(:puts).with("** RSpactor is now watching at '/my/path'")
      setup
    end
  end
  
  describe "#run_spec_command" do
    def with_rubyopt(string)
      old_rubyopt = ENV['RUBYOPT']
      ENV['RUBYOPT'] = string
      begin
        yield
      ensure
        ENV['RUBYOPT'] = old_rubyopt
      end
    end
    
    def run(paths)
      @runner.run_spec_command(paths)
    end
    
    it "should exit if the paths argument is empty" do
      @runner.should_not_receive(:run_command)
      run([])
    end
    
    it "should specify runner spec runner with joined paths" do
      run(%w(foo bar)).should include('spec foo bar')
    end
    
    it "should specify default options: --color" do
      run('foo').should include('--color')
    end
    
    it "should setup RUBYOPT environment variable" do
      with_rubyopt(nil) do
        run('foo').should include("RUBYOPT='-Ilib:spec' ")
      end
    end
    
    it "should concat existing RUBYOPTs" do
      with_rubyopt('-rubygems -w') do
        run('foo').should include("RUBYOPT='-Ilib:spec -rubygems -w' ")
      end
    end
    
    it "should include growl formatter" do
      run('foo').should include('-f RSpactorFormatter:STDOUT')
    end
    
    it "should include 'progress' formatter" do
      run('foo').should include('-f progress')
    end
    
    it "should not include 'progress' formatter if there already are 2 or more formatters" do
      @runner.should_receive(:formatter_opts).and_return('-f foo -f bar')
      run('foo').should_not include('-f progress')
    end
  end
  
end