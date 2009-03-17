require 'rspactor/runner'

describe RSpactor::Runner do
  
  described_class.class_eval do
    def self.run_command(cmd)
      # never shell out in tests
      cmd
    end
  end
  
  def runner
    described_class
  end
  
  def with_env(name, value)
    old_value = ENV[name]
    ENV[name] = value
    begin
      yield
    ensure
      ENV[name] = old_value
    end
  end
  
  describe "setup" do
    before(:each) do
      Dir.stub!(:pwd).and_return('/my/path')
      File.stub!(:exists?).and_return(false)
      runner.stub!(:puts)
      RSpactor::Inspector.stub!(:new)
      RSpactor::Interactor.stub!(:new).and_return(mock('Interactor').as_null_object)
      RSpactor::Listener.stub!(:new).and_return(mock('Listener').as_null_object)
    end
    
    def setup
      runner.load
    end
    
    it "should initialize Inspector" do
      RSpactor::Inspector.should_receive(:new).with('/my/path')
      setup
    end
  
    it "should start Interactor" do
      interactor = mock('Interactor')
      interactor.should_receive(:wait_for_enter_key).with(instance_of(String), 3)
      interactor.should_receive(:start_termination_handler)
      RSpactor::Interactor.should_receive(:new).and_return(interactor)
      setup
    end
  
    it "should run all specs if Interactor isn't interrupted" do
      interactor = mock('Interactor', :start_termination_handler => nil)
      interactor.should_receive(:wait_for_enter_key).and_return(nil)
      RSpactor::Interactor.should_receive(:new).and_return(interactor)
      runner.should_receive(:run_spec_command).with('spec')
      setup
    end
  
    it "should skip running all specs if Interactor is interrupted" do
      interactor = mock('Interactor', :start_termination_handler => nil)
      interactor.should_receive(:wait_for_enter_key).and_return(true)
      RSpactor::Interactor.should_receive(:new).and_return(interactor)
      runner.should_not_receive(:run_spec_command)
      setup
    end
  
    it "should run Listener" do
      listener = mock('Listener')
      listener.should_receive(:run).with('/my/path')
      RSpactor::Listener.should_receive(:new).with(instance_of(Array)).and_return(listener)
      setup
    end
  
    it "should output 'watching' message on start" do
      runner.should_receive(:puts).with("** RSpactor is now watching at '/my/path'")
      setup
    end
    
    it "should load dotfile if found" do
      with_env('HOME', '/home/moo') do
        File.should_receive(:exists?).with('/home/moo/.rspactor').and_return(true)
        Kernel.should_receive(:load).with('/home/moo/.rspactor')
        setup
      end
    end
  end
  
  describe "#run_spec_command" do
    def with_rubyopt(string, &block)
      with_env('RUBYOPT', string, &block)
    end
    
    def run(paths)
      runner.run_spec_command(paths)
    end
    
    it "should exit if the paths argument is empty" do
      runner.should_not_receive(:run_command)
      run([])
    end
    
    it "should specify runner spec runner with joined paths" do
      run(%w(foo bar)).should include(' spec foo bar ')
    end
    
    it "should specify default options: --color" do
      run('foo').should include(' --color')
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
      run('foo').should include(' -f RSpecGrowler:STDOUT')
    end
    
    it "should include 'progress' formatter" do
      run('foo').should include(' -f progress')
    end
    
    it "should not include 'progress' formatter if there already are 2 or more formatters" do
      runner.should_receive(:formatter_opts).and_return('-f foo --format bar')
      run('foo').should_not include('-f progress')
    end
  end
  
  it "should have Runner in global namespace for backwards compatibility" do
    defined?(::Runner).should be_true
    ::Runner.should == runner
  end
  
end